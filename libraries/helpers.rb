# Takes a file and or a url decides if it is a git repo or an archive. downoads or clones it.
def get_files(url, file, destination)
  # "temp_file = "#{Chef::Config['file_cache_path'] || '/tmp'}/#{file}.#{extension[1]}"

  case file.=~(/\.([\w\.]*$)/)
  when 'tar.gz'
    puts 'This is a tar gzip!!'

    file_arch = "#{Chef::Config['file_cache_path'] || '/tmp'}/#{file}"
    remote_file file_arch do
      owner 'root'
      group 'root'
      mode '0644'
      source "#{url}/#{file}"
      not_if File.readable?(file)
    end
    bash "Untar #{file}" do
      cwd ::File.dirname(file_arch)
      code <<-EOH
        tar-xC #{destination} -f #{file};
      EOH
      not_if { ::File.readable(file) }
    end
  when 'zip'
    puts 'This is a zip!!'
    file_arch = "#{Chef::Config['file_cache_path'] || '/tmp'}/#{file}"
    remote_file file_arch do
      owner 'root'
      group 'root'
      mode '0644'
      source "#{url}/#{file}"
      not_if File.readable?(file)
    end
    bash "Unzip #{file}" do
      cwd ::File.dirname(file_arch)
      code <<-EOH
        unzip -d #{destination} -qo #{file};
      EOH
      not_if { ::File.readable(file) }
    end

  when 'git'
    puts 'This is a git repo!!'
    git 'destination' do
      repository "#{url}/#{file}"
      reference 'master'
      user node['apache']['user']
      action :sync
    end

  else
    puts 'This is something else!'
  end
end

# Takes a file and or a url decides if it is a git repo or an archive. downoads or clones it.
def get_files(url, file, destination)
  full_url = "#{url}/#{file}"
  # "temp_file = "#{Chef::Config['file_cache_path'] || '/tmp'}/#{file}.#{extension[1]}"

  puts(/\.([\w\.]*$)/.match(file))
  case /\.([\w\.]*$)/.match(file)
  when 'tar.gz'
    puts 'This is a tar gzip!!'

  when 'zip'
    file_arch = "#{Chef::Config['file_cache_path'] || '/tmp'}/#{file}"
    remote_file file_arch do
      owner 'root'
      group 'root'
      mode '0644'
      source full_url
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

  else
    puts 'This is something else!'
  end
end

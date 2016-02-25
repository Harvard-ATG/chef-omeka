# Takes a file and or a url decides if it is a git repo or an archive.
# Downloads or clones it. to the destination.
# Do not enter url with trailing slash.
def get_files(url, file, destination)
  case File.extname(file)
  when '.tar.gz', '.zip' then unpack_archive(url, file, destination)
  when '.git'
    git 'destination' do
      repository "#{url}/#{file}"
      reference 'master'
      user node['apache']['user']
      action :sync
    end
  else fail ArgumentError, "dunno how to handle #{file}"
  end
end

def unpack_archive(url, file, destination)
  remote_file "#{Chef::Config['file_cache_path'] || '/tmp'}/#{file}" do
    owner 'root'
    group 'root'
    mode '0644'
    source "#{url}/#{file}"
    not_if File.readable?(file)
  end
  bash "Extract #{file}" do
    cwd ::File.dirname("#{Chef::Config['file_cache_path'] || '/tmp'}/#{file}")
    code extract(file, destination)
    only_if ::File.readable?(file)
  end
end

def extract(file, destination)
  case File.extname(file)
  when '.tar.gz' then "tar-xC #{destination} -f #{file};"
  when 'zip' then "unzip -d #{destination} -qo #{file};"
  end
end

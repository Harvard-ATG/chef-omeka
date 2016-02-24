resource_name :instance
default_action :create

property :url, String, name_property: true, default_value: node['hostname']
property :aliaes, Array
property :location, String, default: node['omeka']['location']
property :version, String, default: node['omeka']['version']
property :dir, String, default: '/srv/www/omeka/'
property :instance_owner, String, default: 'omeka_web'
property :db_host, String, default: '127.0.0.1'
property :db_name, String, default: 'omeka'
property :db_user, String, default: 'omeka_user'
property :db_pass, String, default: 'abc123'
property :db_prefix, String, default: 'omeka_'
property :db_charset, String, default: 'utf8'
property :db_socket, String, default: node['omeka']['db_socket']
property :db_port, String, default: node['omeka']['db_port']
property :install_local_mysql_server, [true, false], default: true
property :create_db, [true, false], default: true
property :is_production, [true, false], default: true

action :create do
  # Get the files for a server unzip and move
  #
  user instance_owner do
    action :create
    comment 'Omeka instance_owner'
  end
  directory dir do
    owner instance_owner
    group node['apache']['owner']
    mode '0755'
    recursive true
    action :create
  end

  omeka_zip = "#{Chef::Config['file_cache_path'] || '/tmp'}/omeka-#{version}.zip"
  remote_file omeka_zip do
    owner instance_owner
    mode '0644'
    source "#{location + version}.zip"
  end

  omeka_unzip_folder = "omeka-#{version}"

  bash 'unzip omeka' do
    cwd ::File.dirname(omeka_zip)
    code <<-EOH
    unzip -qo #{omeka_zip};
    rm -rf #{omeka_unzip_folder}/db.ini;
    chown -R #{instance_owner} #{omeka_unzip_folder}
    EOH
    not_if { ::File.directory?(omeka_zip) }
  end

  bash 'copy files' do
    user instance_owner
    cwd ::File.dirname(omeka_zip)
    code <<-EOH
    shopt -s dotglob;
    cp -r #{omeka_unzip_folder}/* #{dir};
    EOH
  end

  template "#{dir}db.ini" do
    source 'db.ini.erb'
    owner instance_owner
    mode '0444'
    action :create
    variables(
      db_host: db_host,
      db_user: db_user,
      db_pass: db_pass,
      db_name: db_name,
      db_prefix: db_prefix,
      db_charset: db_charset,
      db_port: db_port
    )
    cookbook 'omeka'
  end

  directory "#{dir}files" do
    owner node['apache']['user']
    group instance_owner
    mode '0755'
    action :create
  end

  omeka_dirs = %w(fullsize original square_thumbnails theme_uploads thumbnails)
  omeka_dirs.each do |omeka_dir|
    directory "#{dir}files/#{omeka_dir}" do
      owner node['apache']['user']
      group instance_owner
      mode '0755'
      action :create
    end
  end

  # MySQL
  if install_local_mysql_server
    # server
    mysql_service 'default' do
      port db_port
      version '5.6'
      initial_root_password node['omeka']['db_root_pass']
      socket db_socket
      action [:create, :start]
    end

    mysql_config 'default' do
      source 'mysite.cnf.erb'
      notifies :restart, 'mysql_service[default]'
      action :create
    end
  end

  mysql_client 'default' do
    action :create
    not_if { node['platform_family'] == 'windows' }
  end

  mysql2_chef_gem 'default' do
    action :install
  end

  mysql_connection_info = {
    host: db_host,
    username: 'root',
    socket: db_socket,
    password: node['omeka']['db_root_pass']
  }

  mysql_database db_name do
    connection  mysql_connection_info
    action      :create
  end

  mysql_database_user db_user do
    connection    mysql_connection_info
    password      db_pass
    host          db_host
    database_name db_name
    action        :create
  end

  mysql_database_user db_user do
    connection    mysql_connection_info
    database_name db_name
    privileges    [:all]
    action        :grant
  end
  # Web Server configuration
  case node['omeka']['webserver']
  when 'apache2'
    template "#{node['apache']['dir']}/sites-enabled/#{url}" do
      source 'web_app.conf.erb'
      owner 'root'
      group node['apache']['root_group']
      mode '0644'
      variables(
        server_name: url,
        server_aliases: aliaes,
        docroot: dir,
        allow_override: 'All',
        directory_index: 'false'
      )
    end
  when 'nginx'
    # TODO: create nginx vhost file
  end
end

action :delete do
end

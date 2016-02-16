resource_name :instance
default_action :create

property :url, String, name_property: true
property :owner, String
property :location, String, default: node['omeka']['location']
property :version, String, default: node['omeka']['version']
property :directory, String, default_value: '/srv/www/omeka/'
property :owner, String, default_value: 'omeka_web'
property :db_host, String, default_value: '127.0.0.1'
property :db_name, String, default_value: 'omeka'
property :db_user, String, default_value: 'omeka_user'
property :db_pass, String, default_value: 'abc123'
property :db_prefix, String, default_value: 'omeka_'
property :db_charset, String, default_value: 'utf8'
property :db_socket, String, default_value: node['omeka']['db_socket']
property :db_port, String, default_value: node['omeka']['db_port']
property :install_local_mysql_server, String, default_value: true
property :create_db, String, default_value: true
property :is_production, String, default_value: true

action :create do
  user owner do
    action :create
    comment "Omeka instance #{url}, owner"
  end

  directory directory do
    owner owner
    group node['apache']['owner']
    mode '0755'
    recursive true
    action :create
  end

  omeka_zip = "#{Chef::Config['file_cache_path'] || '/tmp'}/omeka-#{version}.zip"
  remote_file omeka_zip do
    owner owner
    mode '0644'
    source "#{location + version}.zip"
  end

  package 'unzip'

  omeka_unzip_folder = "omeka-#{version}"

  bash 'unzip omeka' do
    cwd ::File.dirname(omeka_zip)
    code <<-EOH
    unzip -qo #{omeka_zip};
    rm -rf #{omeka_unzip_folder}/db.ini;
    chown -R #{owner} #{omeka_unzip_folder}
    EOH
    not_if { ::File.directory?(omeka_zip) }
  end

  bash 'copy files' do
    user owner
    cwd ::File.dirname(omeka_zip)
    code <<-EOH
    shopt -s dotglob;
    cp -r #{omeka_unzip_folder}/* #{directory};
    EOH
  end

  template "#{directory}db.ini" do
    source 'db.ini.erb'
    owner owner
    mode '0444'
    action :create
  end

  directory "#{directory}files" do
    owner node['apache']['user']
    group owner
    mode '0755'
    action :create
  end

  omeka_dirs = %w(fullsize original square_thumbnails theme_uploads thumbnails)
  omeka_dirs.each do |omeka_dir|
    directory "#{directory}files/#{omeka_dir}" do
      owner node['apache']['user']
      group owner
      mode '0755'
      action :create
    end
  end
  mysql_client 'default' do
    action :create
  end

  mysql_client 'default' do
    action :create
    not_if { node['platform_family'] == 'windows' }
  end

  mysql2_chef_gem 'default' do
    action :install
  end

  node.save unless Chef::Config[:solo]

  mysql_connection_info = {
    host: db_host,
    username: 'root',
    socket: db_socket,
    password: db_pass
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
  include_recipe 'omeka::database' if create_db

  web_app 'omeka' do
    server_name node['hostname']
    docroot directory
    allow_override 'All'
    directory_index 'false'
    notifies :reload, 'service[apache2]', :delayed
  end
end

action :delete do
end

#
# Cookbook Name:: omeka
# Recipe:: default
#
# Copyright (c) 2016 Harvard ATG, All Rights Reserved.
#
user node['omeka']['owner'] do
  action :create
  comment 'Omeka User'
end

directory node['omeka']['directory'] do
  owner node['omeka']['owner']
  group node['omeka']['owner']
  mode '0755'
  recursive true
  action :create
end

omeka_zip = "#{Chef::Config['file_cache_path'] || '/tmp'}/omeka-#{node['omeka']['version']}.zip"
remote_file omeka_zip do
  owner node['omeka']['owner']
  mode '0644'
  source "#{node['omeka']['location'] + node['omeka']['version']}.zip"
end

package 'unzip'

omeka_unzip_folder = "omeka-#{node['omeka']['version']}"

bash 'unzip omeka' do
  cwd ::File.dirname(omeka_zip)
  code <<-EOH
    unzip -qo #{omeka_zip};
    rm -rf #{omeka_unzip_folder}/db.ini;
    chown -R #{node['omeka']['owner']} #{omeka_unzip_folder}
  EOH
  not_if { ::File.directory?(omeka_zip) }
end

bash 'copy files' do
  user node['omeka']['owner']
  cwd ::File.dirname(omeka_zip)
  code <<-EOH
    shopt -s dotglob;
    cp -r #{omeka_unzip_folder}/* #{node['omeka']['directory']};
  EOH
end

template "#{node['omeka']['directory']}db.ini" do
  source 'db.ini.erb'
  owner node['omeka']['owner']
  mode '0444'
  action :create
end

directory "#{node['omeka']['directory']}files" do
  owner node['apache']['user']
  group node['omeka']['owner']
  mode '0755'
  action :create
end

# Install the mysql client.

mysql_client 'default' do
  action :create
end

web_app 'omeka' do
  server_name node['hostname']
  docroot node['omeka']['directory']
  cookbook 'apache2'
end

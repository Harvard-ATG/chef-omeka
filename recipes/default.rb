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

omeka_zip = "#{Chef::Config['file_cache_path'] || '/tmp/omeka-'}#{node['omeka']['version']}.zip"
remote_file omeka_zip do
  owner node['omeka']['owner']
  mode '0644'
  source "#{node['omeka']['location'] + node['omeka']['version']}.zip"
end

bash 'unzip omeka' do
  user 'root'
  cwd ::File.dirname(omeka_zip)
  code <<-EOH
    unzip #{::File.basename(omeka_zip)} -C #{::File.dirname(omeka_zip)}" &&
    mv omeka-#{node['omeka']['version']}/* #{node['omeka']['directory']}
  EOH
  not_if { ::File.directory?("#{Chef::Config['file_cache_path'] || '/tmp/omeka-'}#{node['omeka']['version']}.zip") }
end

template "#{node['omeka']['directory']}db.ini" do
  source 'db.ini.erb'
  owner node['omeka']['owner']
  mode '0444'
  variables(
    db_host: node['omeka']['db_host'],
    db_user: node['omeka']['db_user'],
    db_pass: node['omeka']['db_pass'],
    db_name: node['omeka']['db_name'],
    db_prefix: node['omeka']['db_prefix'],
    db_charset: node['omeka']['db_charset'],
    db_port: node['omeka']['db_port']
  )
end

mysql_service 'default' do
  port '3306'
  version '5.5'
  initial_root_password node['omeka']['db_password']
  bind_address '127.0.0.1'
  socket '/var/run/mysqld/mysqld.sock'
  action [:create, :start]
end

mysql_config 'default' do
  source 'mysite.cnf.erb'
  notifies :restart, 'mysql_service[default]'
  action :create
end

# Install the mysql client.

mysql_client 'default' do
  action :create
end

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

bash 'unzip omeka' do
  user node['omeka']['owner']
  cwd ::File.dirname(omeka_zip)
  code <<-EOH
    unzip -qo #{omeka_zip};
  EOH
  not_if { ::File.directory?(omeka_zip) }
end

bash 'move files' do
  user node['omeka']['owner']
  cwd ::File.dirname(omeka_zip)
  code <<-EOH
    mv -f omeka-#{node['omeka']['version']}/* #{node['omeka']['directory']};
  EOH
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

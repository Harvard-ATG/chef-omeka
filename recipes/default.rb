#
# Cookbook Name:: omeka
# Recipe:: default
#
# Copyright (c) 2016 Harvard ATG, All Rights Reserved.
#

user node['omeka']['user'] do
  action :create
  comment 'Omeka User'
end

directory node['omeka']['location'] do
  owner 'root'
  group 'root'
  mode '0755'

  action :create
end

omeka_zip = "#{Chef::Config['file_cache_path'] || '/tmp/omeka-'}#{node['omeka']['version']}.zip"
remote_file omeka_zip do
  owner node['omeka']['user']
  group node['nginx']['user']
  mode '0644'
  source node['omeka']['download_url']
end

bash 'unzip omeka' do
  user 'root'
  cwd ::File.dirname(omeka_zip)
  code "unzip #{::File.basename(omeka_zip)} -C #{::File.dirname(omeka_zip)}"
  not_if { ::File.directory?("#{Chef::Config['file_cache_path'] || '/tmp/omeka-'}#{node['omeka']['version']}.zip") }
end

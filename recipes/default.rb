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

remote_file '/tmp/omeka.zip' do
  owner node['omeka']['user']
  group node['nginx']['user']
  mode '0644'
  source 'http://www.example.com/remote_file'
  checksum 'sha256checksum'
end



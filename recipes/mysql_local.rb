#
# Cookbook Name:: omeka
# Recipe:: mysql_local
# Copyright (c) 2016 Harvard ATG, All Rights Reserved.
#

mysql_service 'default' do
  port db_port
  version '5.6'
  initial_root_password db_pass
  socket db_socket
  action [:create, :start]
end

mysql_config 'default' do
  source 'mysite.cnf.erb'
  notifies :restart, 'mysql_service[default]'
  action :create
end
mysql_client 'default' do
  action :create
  not_if { node['platform_family'] } == 'windows'
end

mysql2_chef_gem 'default' do
  action :install
end

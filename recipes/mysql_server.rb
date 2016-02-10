#
# Cookbook Name:: omeka
# Recipe:: mysql_server
#
# Copyright (c) 2016 Harvard ATG, All Rights Reserved.
#

mysql_service 'default' do
  port node['omeka']['db_port']
  version '5.6'
  initial_root_password node['omeka']['db_pass']
  socket node['omeka']['db_socket']
  action [:create, :start]
end

mysql_config 'default' do
  source 'mysite.cnf.erb'
  notifies :restart, 'mysql_service[default]'
  action :create
end

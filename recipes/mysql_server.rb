#
# Cookbook Name:: omeka
# Recipe:: mysql_server
#
# Copyright (c) 2016 Harvard ATG, All Rights Reserved.
#

mysql_service 'default' do
  port '3306'
  version '5.7'
  initial_root_password node['omeka']['db_pass']
  bind_address '127.0.0.1'
  socket '/var/run/mysqld/mysqld.sock'
  action [:create, :start]
end

mysql_config 'default' do
  source 'mysite.cnf.erb'
  notifies :restart, 'mysql_service[default]'
  action :create
end

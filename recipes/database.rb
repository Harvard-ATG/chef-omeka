#
# Cookbook Name:: omeka
# Recipe:: database
#
# Author:: Josh Beauregard <josh_beauregard@harvard.edu>

mysql_client 'default' do
  action :create
  not_if { node['platform_family'] == 'windows' }
end

mysql2_chef_gem 'default' do
  action :install
end

node.save unless Chef::Config[:solo]

mysql_connection_info = {
  host: node['omeka']['db_host'],
  username: 'root',
  socket: node['omeka']['db_socket'],
  password: node['omeka']['db_pass']
}

mysql_database node['omeka']['db_name'] do
  connection  mysql_connection_info
  action      :create
end

mysql_database_user node['omeka']['db_user'] do
  connection    mysql_connection_info
  password      node['omeka']['db_pass']
  host          node['omeka']['db_host']
  database_name node['omeka']['db_name']
  action        :create
end

mysql_database_user node['omeka']['db_user'] do
  connection    mysql_connection_info
  database_name node['omeka']['db_name']
  privileges    [:all]
  action        :grant
end

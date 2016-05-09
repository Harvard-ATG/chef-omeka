#
# Cookbook Name:: omeka
# Recipe:: default
#
# Copyright (c) 2016 Harvard ATG, All Rights Reserved.
#

include_recipe('omeka::mysql_local') if node['omeka']['install_local_mysql_server'] == true
include_recipe('postfix::default') if node['omeka']['postfix'] == true

packages = %w(unzip tar imagemagick git)
# get php ready
case node['platform_family']
when 'rhel', 'fedora'
  packages.push('zlib-devel', 'httpd-devel', 'pcre', 'pcre-devel', 'php-mysql', 'php-gd')
when 'debian'
  packages.push('php5-memcache', 'php5-gd', 'php5-mysql', 'apache2-mpm-prefork')
end
packages.each do |p|
  package p do
    action :install
  end
end

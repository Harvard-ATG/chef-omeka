#
# Cookbook Name:: omeka
# Recipe:: default
#
# Copyright (c) 2016 Harvard ATG, All Rights Reserved.
#

recipes = {
  node['omeka']['install_local_mysql_server'] => 'omeka::mysql_local',
  node['omeka']['postfix'] => 'postfix::default'
}

recipes.each do |c, r|
  include_recipe(r) if c == true
end

packages = %w(unzip tar imagemagick)
      # get php ready
      case node['platform_family']
      when 'rhel', 'fedora'
        packages.push('zlib-devel', 'httpd-devel', 'pcre', 'pcre-devel', 'php-mysql', 'php-gd')
      when 'debian'
        packages.push('php5-memcache', 'php5-gd', 'php5-mysql')
      end
packages.each do |p|
  package p do
    action :install
  end
end

#
# Cookbook Name:: omeka
#

default['omeka']['location'] = 'http://omeka.org/files/omeka-'
default['omeka']['version'] = '2.4'
default['omaka']['user'] = 'omeka_web'
default['omeka']['location'] = '/srv/www/omeka/'
default['omeka']['dowload_url'] = "#{node['omeka']['location'] + node['omeka']['location'] + node['omeka']['version']}.zip"

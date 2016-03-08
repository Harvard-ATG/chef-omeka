#
# Cookbook Name:: omeka
#

default['omeka']['location'] = 'http://omeka.org/files/omeka-'
default['omeka']['webserver'] = 'apache2'
default['omeka']['version'] = '2.4'
default['omaka']['user'] = 'omeka_web'
default['omeka']['directory'] = '/srv/www/omeka/'
default['omeka']['owner'] = 'omeka_web'
default['omeka']['db_host'] = '127.0.0.1'
default['omeka']['db_name'] = 'omeka'
default['omeka']['db_user'] = 'omeka_user'
default['omeka']['db_pass'] = 'abc123'
default['omeka']['db_root_pass'] = 'reallyHardToGuess'
default['omeka']['db_prefix'] = 'omeka_'
default['omeka']['db_charset'] = 'utf8'
default['omeka']['db_socket'] = '/var/run/mysqld/mysqld.sock'
default['omeka']['db_port'] = '3306'
default['omeka']['install_local_mysql_server'] = true
default['omeka']['create_db'] = true
default['omeka']['is_production'] = true

# omeka plugins
# Source of Plugins: http://omeka.org/add-ons/plugins/
default['omeka']['addons']['location'] = 'http://omeka.org/wordpress/wp-content/uploads'
default['omeka']['addons']['plugins'] = []

# omeka themes
default['omeka']['addons']['themes'] = []

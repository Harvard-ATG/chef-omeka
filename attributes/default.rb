#
# Cookbook Name:: omeka
#

default['omeka']['location'] = 'http://omeka.org/files/omeka-'
default['omeka']['version'] = '2.4'
default['omaka']['user'] = 'omeka_web'
default['omeka']['directory'] = '/srv/www/omeka/'
default['omeka']['owner'] = 'omeka_web'
default['omeka']['db_host'] = '127.0.0.1'
default['omeka']['db_name'] = 'omeka'
default['omeka']['db_user'] = 'omeka_user'
default['omeka']['db_pass'] = 'abc123'
default['omeka']['db_prefix'] = 'omeka_'
default['omeka']['db_charset'] = 'utf8'
default['omeka']['db_socket'] = '/var/run/mysqld/mysqld.sock'
default['omeka']['db_port'] = '3306'
default['omeka']['install_local_mysql_server'] = true
default['omeka']['create_db'] = true
default['omeka']['is_production'] = true

# php apc values
default['omeka']['apc']['shm_segments']	= '2'
default['omeka']['apc']['shm_size ']	= '256M'
default['omeka']['apc']['ttl']	= '7200'
default['omeka']['apc']['user_ttl']	= '7200'
default['omeka']['apc']['enable_cli']	= '1'
default['omeka']['apc']['stat']	= '0'
default['omeka']['apc']['stat_ctime']	= '1'
default['omeka']['apc']['lazy_classes']	= '0'
default['omeka']['apc']['lazy_functions']	= '0'
default['omeka']['apc']['write_lock']	= '1'
default['omeka']['apc']['rfc1867'] = '1'

# omeka plugins
# Source of Plugins: http://omeka.org/add-ons/plugins/
# they are all zipped and the extension will be added at the end
default['omeka']['plugins']['location'] = "http://omeka.org/wordpress/wp-content/uploads/"
default['omeka']['plugins']['neatline'] = "Neatline-2.5.1"
default['omeka']['plugins']['neatlinefeatures'] = "NeatlineFeatures-2.0.5"
default['omeka']['plugins']['neatlinesimile'] = "Neatline-Widget-SIMILE-Timeline-2.0.4"
default['omeka']['plugins']['neatlinetext'] = "Neatline-Widget-Text-1.1.0"
default['omeka']['plugins']['neatlinetime'] = "Neatline-Time-2.1.0"
default['omeka']['plugins']['neatlinewaypoints'] = "Neatline-Widget-Waypoints-2.0.2"
default['omeka']['plugins']['universalviewer'] = "UniversalViewer-2.2"
default['omeka']['plugins']['iiif'] = "IIIF-1.0"






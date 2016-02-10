#
# Cookbook Name:: omeka
#

default['omeka']['location'] = 'http://omeka.org/files/omeka-'
default['omeka']['version'] = '2.4'
default['omaka']['user'] = 'omeka_web'
default['omeka']['directory'] = '/srv/www/omeka/'
default['omeka']['owner'] = 'omeka_web'
default['omeka']['db_host'] = 'localhost'
default['omeka']['db_name'] = 'omeka'
default['omeka']['db_user'] = 'omeka'
default['omeka']['db_pass'] = 'abc123'
default['omeka']['db_prefix'] = 'omeka_'
default['omeka']['harset'] = 'utf8'
default['omeka']['db_port'] = ''
default['omeka']['install_local_mysql_server'] = true

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

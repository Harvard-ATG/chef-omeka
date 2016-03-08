require 'spec_helper'

files = %w(
  /srv/www/omeka/index.php
  /srv/www/omeka/.htaccess
  /srv/www/omeka/db.ini
  /srv/www/omeka/plugins/Neatline/NeatlinePlugin.php
  /srv/www/omeka/themes/berlin/index.php
)

services = %w(mysqld_default)

case os[:family]
when 'ubuntu'
  files << '/etc/apache2/sites-enabled/omeka.dev.conf'
  services << 'apache2'

when 'redhat'
  files << '/etc/httpd/sites-enabled/omeka.dev.conf'
  services << 'httpd'
end

files.each do |file|
  describe file(file) do
    it { should exist }
  end
end
services.each do |s|
  describe service(s) do
    it { should be_enabled }
  end
end

describe user('omeka_web') do
  it { should exist }
end

ports = %w(443 80 3306)
ports.each do |port|
  describe port (port) do
    it { should be_listening }
  end
end

describe 'MySQL config parameters' do
  mysql_config('socket') do
    its(:value) { should eq '/var/run/mysqld/mysqld.sock' }
  end
end

describe command('curl -L localhost') do
  # its(:stdout) { should match /omeka/i }
end

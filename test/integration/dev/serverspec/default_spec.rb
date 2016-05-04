require 'spec_helper'

files = %w(
  /srv/www/omeka.dev/index.php
  /srv/www/omeka.dev/.htaccess
  /srv/www/omeka.dev/db.ini
  /srv/www/omeka.dev/plugins/Neatline/NeatlinePlugin.php
  /srv/www/omeka.dev/themes/berlin/index.php
)

services = %w(postfix)

case os[:family]
when 'ubuntu'
  files << '/etc/apache2/sites-enabled/omeka.dev.conf'
  services << 'mysql-default'
  services << 'apache2'

when 'redhat'
  files << '/etc/httpd/sites-enabled/omeka.dev.conf'
  services << 'httpd'
  services << 'mysqld-default'
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

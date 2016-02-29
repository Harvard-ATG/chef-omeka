require 'spec_helper'

files = %w(/srv/www/omeka/index.php /srv/www/omeka/.htaccess /srv/www/omeka/db.ini /srv/www/omeka/plugins/Neatline/NeatlinePlugin.php)
case os[:family]
when 'ubuntu'
  files << '/etc/apache2/sites-enabled/omeka.dev.conf'
when 'redhat'
  files << '/etc/httpd/sites-enabled/omeka.dev.conf'
end

files.each do |file|
  describe file(file) do
    it { should exist }
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

describe command('curl localhost') do
  its(:stdout) { should contain('Omeka') }
end

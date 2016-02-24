require 'spec_helper'

def ws
  case os[:family]
  when ubuntu
    return 'apache2'
  when 'redhat'
    return 'httpd'
  end
end

describe user('omeka_web') do
  it { should exist }
end

files = %w(/srv/www/omeka/index.php /srv/www/omeka/.htaccess /srv/www/omeka/db.ini /etc/httpd/sites-enabled/omeka.dev)

files.each do |file|
  describe file(file) do
    it { should exist }
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

describe command('curl localhost') do
  its(:stdout) { should contain('omeka') }
end

require 'spec_helper'

files = %w()

services = %w(postfix)

case os[:family]
when 'ubuntu'
  services << 'mysql-default'
  services << 'apache2'

when 'redhat'
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

describe package('mysql2') do
  it { should be_installed.by('gem') }
end

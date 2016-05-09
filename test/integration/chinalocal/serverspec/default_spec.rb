require 'spec_helper'

omeka_app_dir = '/srv/www/omeka.dev'

omeka_files_dirs = [
  "#{omeka_app_dir}/files/fullsize",
  "#{omeka_app_dir}/files/original",
  "#{omeka_app_dir}/files/square_thumbnails",
  "#{omeka_app_dir}/files/theme_uploads",
  "#{omeka_app_dir}/files/thumbnails"
]
files = [
  "#{omeka_app_dir}/index.php",
  "#{omeka_app_dir}/.htaccess",
  "#{omeka_app_dir}/db.ini",
  "#{omeka_app_dir}/plugins/Neatline/NeatlinePlugin.php",
  "#{omeka_app_dir}/themes/berlin/index.php"
]
files.concat( omeka_files_dirs )

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

omeka_files_dirs.each do |dir|
  describe file(dir) do
    it { should be_directory }
    it { should be_writable.by('owner') }
  end
end
describe command('wget -qO- localhost') do
  its(:stdout) { should match /omeka/i }
  its(:stdout) { should_not match /Installation Error/i }
end

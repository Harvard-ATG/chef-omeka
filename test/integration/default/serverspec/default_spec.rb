require 'spec_helper'

describe user('omeka_web') do
  it { should exist }
end

files = %w(/srv/www/omeka/index.php /srv/www/omeka/.htaccess /srv/www/omeka/db.ini)

files.each do |file|
  describe file(file) do
    it { should exist }
  end
end

ports = %w(80, 443)

ports.each do |port|
  describe port (port) do
    it { should be_listening }
  end
end

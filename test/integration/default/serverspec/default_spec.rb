require 'spec_helper'

services = %w(mysql php-fpm nginx)

services.each do |s|
  describe service(s) do
    it { should be_enabled }
  end
end

describe user('omeka_web') do
  it { should should exist }
  it { should belong_to_group 'www-data' }
end

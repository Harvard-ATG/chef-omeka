#
# Cookbook Name:: omeka
# Recipe:: default
#
# Copyright (c) 2016 Harvard ATG, All Rights Reserved.
#
packages = %w(unzip tar imagemagick)
packages.each do |p|
  package p do
    action :install
  end
end

# condion => recipe
recipes = {
  node['omeka']['create_local_db'] => 'omeka::mysql_local',
  node['omeka']['postfix'] => 'postfix::default'
}

recipes.each {|c, r|
  include_recipe(r) if c
}

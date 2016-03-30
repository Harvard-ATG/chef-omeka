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

include_recipe('postfix::default') if node['omeka']['postfix']
#
# Cookbook Name:: omeka
# Recipe:: solo
#
# Copyright (c) 2016 Harvard ATG, All Rights Reserved.
#
# TODO: temp package adding, waitng for lib resource
include_recipe 'omeka::default'

omeka_instance 'omeka.dev' do
  notifies :reload, 'service[apache2]', :delayed
end

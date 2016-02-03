#
# Cookbook Name:: omeka
# Spec:: default
#
# Copyright (c) 2016 Harvard ATG, All Rights Reserved.

require 'spec_helper'

describe 'omeka::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

  end
end

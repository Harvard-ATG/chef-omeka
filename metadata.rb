name 'omeka'
maintainer 'Harvard ATG'
maintainer_email 'josh_beauregard@harvard.edu'
license 'MIT License'
description 'A helper for a LAMP Stack running Omeka'
long_description <<-EOH
[![Build Status](https://travis-ci.org/Harvard-ATG/chef-omeka.svg?branch=master)](https://travis-ci.org/Harvard-ATG/chef-omeka)

A helper Stack for running the Omeka (http://omeka.org), software stack.

It will install bare omeka install at localhost.

If you are running kitchen converge it will forward port 8080 to 80 so you can access it in your local browser.

### To Do
* Add attributes and themes.
* Make omeka LWRP so that an instance is an lwap and not just the defualt recipe.
EOH
version '0.2.0'

depends 'build-essential', '~> 2.2.4'
depends 'yum', '~> 3.5.2'
depends 'mysql', '~> 6.1.2'
depends 'php', '~> 1.7.2'
depends 'zip', '~> 1.1.0'
depends 'tomcat', '~> 1.0.1'
depends 'apache2'
depends 'database', '>= 1.6.0'
depends 'mysql2_chef_gem', '~> 1.0.1'

supports 'centos'
supports 'ubuntu'

issues_url 'https://github.com/Harvard-ATG/chef-omeka/issues'
source_url 'https://github.com/Harvard-ATG/chef-omeka'

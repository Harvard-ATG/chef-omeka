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

## Use

For a single omeka instance just add omeka::solo to your runlist.

For muliple instances you will need to use the `omeka_instance` resource per instance.
Test Kitchen
============
Test kitchen is setup using the kitchen docker-driver. Install it with:
```
chef gem install kitchen-docker
```

Port forwarding.
The 3 boxes created by test kitchen have the bellow port 80 forwared.`docker ps`, will list instance and where they are forwared to.
EOH
version '0.4.6'

depends 'build-essential', '~> 2.2.4'
depends 'yum', '~> 3.5.2'
depends 'mysql', '~> 6.1.2'
depends 'php', '~> 1.7.2'
depends 'apache2'
depends 'database', '>= 1.6.0'
depends 'mysql2_chef_gem', '~> 1.0.1'
depends 'postfix', '~> 3.7.0'
depends 'poise', '~> 2.6.0'
supports 'centos'
supports 'ubuntu'

issues_url 'https://github.com/Harvard-ATG/chef-omeka/issues'
source_url 'https://github.com/Harvard-ATG/chef-omeka'

recipe 'omeka::default', 'Base requirements for omeka. Include in your custom cookbook or add in runlist if using the omkea_instance resource provider'
recipe 'omeka::solo', 'Creates a single omeka instance'
provides 'omeka_instance[omeka.tld]'

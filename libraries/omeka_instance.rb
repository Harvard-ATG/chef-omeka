require 'poise'
require 'chef/resource'
require 'chef/provider'

module OmekaInstance
  class Resource < Chef::Resource
    include Poise
    provides(:omeka_instance)
    actions(:create)

    attribute(:url, String, name_property: true, default_value: node['hostname'])
    attribute(:aliaes, Array)
    attribute(:location, String, default: node['omeka']['location'])
    attribute(:version, String, default: node['omeka']['version'])
    attribute(:dir, String, default: '/srv/www/omeka/')
    attribute(:instance_owner, String, default: 'omeka_web')
    attribute(:db_host, String, default: '127.0.0.1')
    attribute(:db_name, String, default: 'omeka')
    attribute(:db_user, String, default: 'omeka_user')
    attribute(:db_pass, String, default: 'abc123')
    attribute(:db_prefix, String, default: 'omeka_')
    attribute(:db_charset, String, default: 'utf8')
    attribute(:db_socket, String, default: node['omeka']['db_socket'])
    attribute(:db_port, String, default: node['omeka']['db_port'])
    attribute(:install_local_mysql_server, [true, false], default: true)
    attribute(:create_db, [true, false], default: true)
    attribute(:is_production, [true, false], default: true)
    attribute(:addons_location, String, default: node['omeka']['addons']['location'])
    attribute(:plugins_list, Array, default: node['omeka']['addons']['plugins'])
  end

  class Provider < Chef::Provider
    include Poise
    provides(:omeka_instance)

    def action_create
      # get php ready
      case node['platform_family']
      when 'rhel', 'fedora'
        %w( zlib-devel httpd-devel pcre pcre-devel php-mysql php-gd ).each do |pkg|
          package pkg do
            action :install
          end
        end
      when 'debian'
        %w( php5-memcache php5-gd php5-mysql ).each do |pkg|
          package pkg do
            action :upgrade
          end
        end
      end
      # Get the files for a server unzip and move
      #
      user instance_owner do
        action :create
        comment 'Omeka instance_owner'
      end
      directory dir do
        owner instance_owner
        group node['apache']['owner']
        mode '0755'
        recursive true
        action :create
      end

      omeka_zip = "#{Chef::Config['file_cache_path'] || '/tmp'}/omeka-#{version}.zip"
      remote_file omeka_zip do
        owner instance_owner
        mode '0644'
        source "#{location + version}.zip"
      end

      omeka_unzip_folder = "omeka-#{version}"

      bash 'unzip omeka' do
        cwd ::File.dirname(omeka_zip)
        code <<-EOH
        unzip -qo #{omeka_zip};
        rm -rf #{omeka_unzip_folder}/db.ini;
        chown -R #{instance_owner} #{omeka_unzip_folder}
        EOH
        not_if { ::File.directory?(omeka_zip) }
      end

      bash 'copy files' do
        user instance_owner
        cwd ::File.dirname(omeka_zip)
        code <<-EOH
        shopt -s dotglob;
        cp -r #{omeka_unzip_folder}/* #{dir};
        EOH
      end

      template "#{dir}db.ini" do
        source 'db.ini.erb'
        owner instance_owner
        mode '0444'
        action :create
        variables(
          db_host: db_host,
          db_user: db_user,
          db_pass: db_pass,
          db_name: db_name,
          db_prefix: db_prefix,
          db_charset: db_charset,
          db_port: db_port
        )
        cookbook 'omeka'
      end

      directory "#{dir}files" do
        owner node['apache']['user']
        group instance_owner
        mode '0755'
        action :create
      end

      omeka_dirs = %w(fullsize original square_thumbnails theme_uploads thumbnails)
      omeka_dirs.each do |omeka_dir|
        directory "#{dir}files/#{omeka_dir}" do
          owner node['apache']['user']
          group instance_owner
          mode '0755'
          action :create
        end
      end

      # Get Omeka Plugins.
      plugins_list.each do |p|
        get_files(addons_location, p, "#{dir}plugins")
      end
      # Get Omeka These.
      themes_list.each do |p|
        get_files(addons_location, p, "#{dir}themes")
      end

      # MySQL
      if install_local_mysql_server
        # server
        mysql_service 'default' do
          port db_port
          version '5.6'
          initial_root_password node['omeka']['db_root_pass']
          socket db_socket
          action [:create, :start]
        end

        mysql_config 'default' do
          source 'mysite.cnf.erb'
          notifies :restart, 'mysql_service[default]'
          action :create
        end
      end

      mysql_client 'default' do
        action :create
        not_if { node['platform_family'] == 'windows' }
      end

      mysql2_chef_gem 'default' do
        action :install
      end

      mysql_connection_info = {
        host: db_host,
        username: 'root',
        socket: db_socket,
        password: node['omeka']['db_root_pass']
      }

      mysql_database db_name do
        connection  mysql_connection_info
        action      :create
      end

      mysql_database_user db_user do
        connection    mysql_connection_info
        password      db_pass
        host          db_host
        database_name db_name
        action        :create
      end

      mysql_database_user db_user do
        connection    mysql_connection_info
        database_name db_name
        privileges    [:all]
        action        :grant
      end
      # Web Server configuration
      case node['omeka']['webserver']
      when 'apache2'
        template "#{node['apache']['dir']}/sites-enabled/#{url}.conf" do
          source 'web_app.conf.erb'
          owner 'root'
          group node['apache']['root_group']
          mode '0644'
          variables(
            server_name: url,
            server_aliases: aliaes,
            docroot: dir,
            allow_override: 'All',
            directory_index: 'false'
          )
          notifies :reload, Chef.run_context.resource_collection.find('service[apache2]')
        end
      when 'nginx'
        # TODO: create nginx vhost file
      end
      notifying_block do
      end
    end
  end
end

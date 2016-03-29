require 'poise'
require 'chef/resource'
require 'chef/provider'

module OmekaInstance
  class Resource < Chef::Resource
    include Poise
    provides(:omeka_instance)
    actions(:create)

    attribute(:url, String, name_property: true, default_value: lazy { node['hostname'] })
    attribute(:aliaes, Array)
    attribute(:location, String, default: lazy { node['omeka']['location'] })
    attribute(:version, String, default: lazy { node['omeka']['version'] })
    attribute(:instance_owner, String, default: 'omeka_web')
    attribute(:db_host, String, default: '127.0.0.1')
    attribute(:db_name, String, default: 'omeka')
    attribute(:db_user, String, default: 'omeka_user')
    attribute(:db_pass, String, default: 'abc123')
    attribute(:db_prefix, String, default: 'omeka_')
    attribute(:db_charset, String, default: 'utf8')
    attribute(:db_socket, String, default: lazy { node['omeka']['db_socket'] })
    attribute(:db_port, String, default: lazy { node['omeka']['db_port'] })
    attribute(:install_local_mysql_server, [true, false], default: true)
    attribute(:create_db, [true, false], default: true)
    attribute(:is_production, [true, false], default: true)
    attribute(:addons_location, String, default: lazy { node['omeka']['addons']['location'] })
    attribute(:plugins_list, Array, default: lazy { node['omeka']['addons']['plugins'] })
    attribute(:themes_list, Array, default: lazy { node['omeka']['addons']['themes'] })
  end

  def dir
    new_resource.url
  end

  class Provider < Chef::Provider
    include Poise
    provides(:omeka_instance)

    def action_create
      # get php ready
      case lazy { node['platform_family'] }
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
      user new_resource.instance_owner do
        action :create
        comment 'Omeka new_resource.instance_owner'
      end
      directory dir do
        owner new_resource.instance_owner
        group lazy { node['apache']['owner'] }
        mode '0755'
        recursive true
        action :create
      end

      omeka_zip = "#{Chef::Config['file_cache_path'] || '/tmp'}/omeka-#{new_resource.version}.zip"
      remote_file omeka_zip do
        owner new_resource.instance_owner
        mode '0644'
        source "#{new_resource.location + new_resource.version}.zip"
      end

      omeka_unzip_folder = "omeka-#{new_resource.version}"

      bash 'unzip omeka' do
        cwd ::File.dirname(omeka_zip)
        code <<-EOH
        unzip -qo #{omeka_zip};
        rm -rf #{omeka_unzip_folder}/db.ini;
        chown -R #{new_resource.instance_owner} #{omeka_unzip_folder}
        EOH
        not_if { ::File.directory?(omeka_zip) }
      end

      bash 'copy files' do
        user new_resource.instance_owner
        cwd ::File.dirname(omeka_zip)
        code <<-EOH
        shopt -s dotglob;
        cp -r #{omeka_unzip_folder}/* #{dir};
        EOH
      end

      template "#{dir}db.ini" do
        source 'db.ini.erb'
        owner new_resource.instance_owner
        mode '0444'
        action :create
        variables(
          db_host: new_resource.db_host,
          db_user: new_resource.db_user,
          db_pass: new_resource.db_pass,
          db_name: new_resource.db_name,
          db_prefix: new_resource.db_prefix,
          db_charset: new_resource.db_charset,
          db_port: new_resource.db_port
        )
        cookbook 'omeka'
      end

      directory "#{dir}files" do
        owner lazy { node['apache']['user'] }
        group new_resource.instance_owner
        mode '0755'
        action :create
      end

      omeka_dirs = %w(fullsize original square_thumbnails theme_uploads thumbnails)
      omeka_dirs.each do |omeka_dir|
        directory "#{dir}files/#{omeka_dir}" do
          owner lazy { node['apache']['user'] }
          group new_resource.instance_owner
          mode '0755'
          action :create
        end
      end

      # Get Omeka Plugins.
      new_resource.plugins_list.each do |p|
        get_files(new_resource.addons_location, p, "#{dir}plugins")
      end
      # Get Omeka These.
      new_resource.themes_list.each do |p|
        get_files(new_resource.addons_location, p, "#{dir}themes")
      end

      # MySQL
      if new_resource.install_local_mysql_server
        # server
        mysql_service 'default' do
          port new_resource.db_port
          version '5.6'
          initial_root_password lazy { node['omeka']['db_root_pass'] }
          socket new_resource.db_socket
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
        not_if { lazy { node['platform_family'] } == 'windows' }
      end

      mysql2_chef_gem 'default' do
        action :install
      end

      mysql_connection_info = {
        host: new_resource.db_host,
        username: 'root',
        socket: new_resource.db_socket,
        password: lazy { node['omeka']['db_root_pass'] }
      }

      mysql_database new_resource.db_name do
        connection  mysql_connection_info
        action      :create
      end

      mysql_database_user new_resource.db_user do
        connection    mysql_connection_info
        password      new_resource.db_pass
        host          new_resource.db_host
        database_name new_resource.db_name
        action        :create
      end

      mysql_database_user new_resource.db_user do
        connection    mysql_connection_info
        database_name new_resource.db_name
        privileges    [:all]
        action        :grant
      end
      # Web Server configuration
      case lazy { node['omeka']['webserver'] }
      when 'apache2'
        template "#{lazy { node['apache']['dir'] }}/sites-enabled/#{new_resource.url}.conf" do
          source 'web_app.conf.erb'
          owner 'root'
          group lazy { node['apache']['root_group'] }
          mode '0644'
          variables(
            server_name: new_resource.url,
            server_aliases: new_resource.aliaes,
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

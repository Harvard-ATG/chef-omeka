require 'poise'
require 'chef/resource'
require 'chef/provider'

module OmekaInstance
  ##
  # Poise Resource for an omeka site instance
  ##
  class Resource < Chef::Resource
    include Poise
    provides(:omeka_instance)
    actions(:create)

    attribute(:url, kind_of: String, default: lazy { name })
    attribute(:aliaes, kind_of: Array)
    attribute(:location, kind_of: String, default: lazy { node['omeka']['location'] })
    attribute(:version, kind_of: String, default: lazy { node['omeka']['version'] })
    attribute(:dir, kind_of: String)
    attribute(:instance_owner, kind_of: String, default: lazy { node['omeka']['owner'] })
    attribute(:db_host, kind_of: String, default: '127.0.0.1')
    attribute(:db_name, kind_of: String)
    attribute(:db_user, kind_of: String)
    attribute(:db_pass, kind_of: String, default: 'abc123')
    attribute(:db_prefix, kind_of: String, default: 'omeka_')
    attribute(:db_charset, kind_of: String, default: 'utf8')
    attribute(:db_socket, kind_of: String, default: lazy { node['omeka']['db_socket'] })
    attribute(:db_port, kind_of: String, default: lazy { node['omeka']['db_port'] })
    attribute(:create_db, kind_of: [true, false], default: true)
    attribute(:is_production, kind_of: [true, false], default: true)
    attribute(:addons_location, kind_of: String, default: lazy { node['omeka']['addons']['location'] })
    attribute(:plugins_list, kind_of: Array, default: lazy { node['omeka']['addons']['plugins'] })
    attribute(:themes_list, kind_of: Array, default: lazy { node['omeka']['addons']['themes'] })
  end

  ##
  # Provider for an omeka site instance
  ##
  class Provider < Chef::Provider
    include Poise
    provides(:omeka_instance)

    def dir
      new_resource.dir.nil? ? "/srv/www/#{new_resource.url}/" : new_resource.dir
    end

    def db_user
      new_resource.db_user.nil? ? new_resource.url.tr('.', '_')[0, 15] : new_resource.db_user[0, 15]
    end

    def db_name
      new_resource.db_name.nil? ? new_resource.url.tr('.', '_')[0, 15] : new_resource.db_name[0, 15]
    end

    def webserver_user
      case node['omeka']['webserver']
      when 'apache2'
        node['apache']['user']
      when 'nginx'
        # TODO: placeholder for nginx
      end
    end

    def action_create
      # Get the files for a server unzip and move
      #
      user new_resource.instance_owner do
        action :create
        comment 'Omeka new_resource.instance_owner'
      end

      directory dir do
        owner new_resource.instance_owner
        group webserver_user
        mode '0755'
        recursive true
        action :create
      end

      omeka_zip = "#{Chef::Config['file_cache_path'] || '/tmp'}/omeka-#{new_resource.version}.zip"
      remote_file omeka_zip do
        owner new_resource.instance_owner
        mode '0644'
        source "#{new_resource.location + new_resource.version}.zip"
        not_if { ::File.readable?(omeka_zip) }
      end

      omeka_unzip_folder = "omeka-#{new_resource.version}"

      bash 'unzip omeka' do
        cwd ::File.dirname(omeka_zip)
        code <<-EOH
        unzip -qo #{omeka_zip};
        rm -rf #{omeka_unzip_folder}/db.ini;
        chown -R #{new_resource.instance_owner} #{omeka_unzip_folder}
        EOH
        only_if { ::File.readable?(omeka_zip) }
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
          db_user: db_user,
          db_pass: new_resource.db_pass,
          db_name: db_name,
          db_prefix: new_resource.db_prefix,
          db_charset: new_resource.db_charset,
          db_port: new_resource.db_port
        )
        cookbook 'omeka'
      end

      directory "#{dir}files" do
        owner webserver_user
        group new_resource.instance_owner
        mode '0755'
        action :create
      end

      omeka_dirs = %w(fullsize original square_thumbnails theme_uploads thumbnails)
      omeka_dirs.each do |omeka_dir|
        directory "#{dir}files/#{omeka_dir}" do
          owner webserver_user
          group new_resource.instance_owner
          mode '0755'
          action :create
        end
      end

      # Get Omeka Plugins.
      new_resource.plugins_list.each do |p|
        get_files(new_resource.addons_location, p, "#{dir}plugins", new_resource.instance_owner)
      end
      # Get Omeka These.
      new_resource.themes_list.each do |p|
        get_files(new_resource.addons_location, p, "#{dir}themes", new_resource.instance_owner)
      end

      bash 'reset theme permissions' do
        user 'root'
        cwd dir
        code "chown -R #{new_resource.instance_owner}:#{new_resource.instance_owner} themes"
      end
      bash 'reset plugins permissions' do
        user 'root'
        cwd dir
        code "chown -R #{new_resource.instance_owner}:#{new_resource.instance_owner} themes plugins"
      end

      # MySQL

      mysql_connection_info = {
        host: new_resource.db_host,
        username: 'root',
        socket: new_resource.db_socket,
        password: node['omeka']['db_root_pass']
      }

      mysql_database db_name do
        connection  mysql_connection_info
        action      :create
      end

      mysql_database_user db_user do
        connection    mysql_connection_info
        password      new_resource.db_pass
        host          new_resource.db_host
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
        template "#{node['apache']['dir']}/sites-enabled/#{new_resource.url}.conf" do
          source 'web_app.conf.erb'
          owner 'root'
          group node['apache']['root_group']
          mode '0644'
          variables(
            server_name: new_resource.url,
            server_aliases: new_resource.aliaes,
            docroot: dir,
            allow_override: 'All',
            directory_index: 'false'
          )
          cookbook 'omeka'
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

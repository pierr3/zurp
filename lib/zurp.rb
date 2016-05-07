require "zurp/version"
require "zurp/nginx"
require "zurp/virtualhost"
require File.join(Gem.datadir("zurp"), "nginx", "nginxvh")
require "thor"
require "terminal-table"

module Zurp
  class CLI < Thor
    @@nginx = Zurp::Nginx.new

    desc "datadir", "Returns the path to the data directory of the gem"
    def datadir
      puts Gem.datadir("zurp")
    end

    desc "new <name> <host>", "Creates a new virtual host"
    option :root, :banner => "ROOT", :type => :string, :aliases => "-r", :desc => "Specify the root for the virtual host"
    option :port, :banner => "PORT", :type => :string, :aliases => "-p", :desc => "Specify the port of the vhost"
    option :ssl, :banner => "SSL", :type => :boolean, :aliases => "-s", :desc => "Enables SSL for the virtual host"
    option :ssl_cert, :banner => "SSLCERT", :type => :string, :aliases => "-c", :desc => "Path to the SSL certificate"
    option :ssl_key, :banner => "SSLKEY", :type => :string, :aliases => "-k", :desc => "Path to the SSL private key"
    option :passenger, :banner => "PASSENGER", :type => :boolean, :aliases => "-a",
           :desc => "Enables passenger for the virtual host"
    option :passenger_startup_file, :banner => "PASSENGERSTARTUPFILE", :type => :string, :aliases => "-f",
           :desc => "Path to the passenger start up file"
    option :php, :banner => "PHP", :type => :boolean, :aliases => "-h",
           :desc => "Enables PHP with php-fpm for the virtual host"
    option :laravel, :banner => "LARAVEL", :type => :boolean, :aliases => "-l",
           :desc => "Enables PHP with laravel support"
    option :php_socket, :banner => "PHP", :type => :string, :aliases => "-j",
           :desc => "Specifies the php-fpm socket address"
    option :error_log, :banner => "ERRORLOG", :type => :string, :aliases => "-e",
           :desc => "Specifies error log file"
    option :access_log, :banner => "ACCESSLOG", :type => :string, :aliases => "-x",
           :desc => "Specifies the access log file"
    options :ipv6 => :boolean, :ipv6only => :boolean
    def new(name, host)
      root = options[:root] ? options[:root] : File.join(@@nginx.www_directory, name)
      vhost_path = File.join(@@nginx.vh_available_directory, name)

      if options[:ssl]
        if not options[:ssl_cert] or not options[:ssl_key]
          put "If you require SSL, please specify the SSLCERT and SSLKEY arguments"
          return
        end
      end

      unless Dir.exist? root
        puts "The directory #{root} does not exist, do you still wish to continue?"
        printf "Press 'y' to continue: "
        prompt = STDIN.gets.chomp
        return unless prompt == 'y'
      end

      if File.exist? vhost_path
        puts "The vhost #{name} already exists, would you like to override it?"
        printf "Press 'y' to continue: "
        prompt = STDIN.gets.chomp
        return unless prompt == 'y'
      end

      puts "Creating virtualhost #{name}..."

      vh = NginxVirtualHost
      vh.set :root, root
      vh.set :server_name, host
      vh.port(options[:port]) if options[:port]

      vh.ssl(options[:ssl_cert], options[:ssl_key]) if options[:ssl]

      vh.ipv6(options[:ipv6only]) if options[:ipv6]

      vh.passenger(options[:passenger_startup_file]) if options[:passenger]

      php_socket = @@nginx.php_fpm
      php_socket = options[:php_socket] if options[:php_socket]

      vh.php(php_socket) if options[:php]

      vh.laravel(php_socket) if options[:laravel]

      vh.set :error_log, options[:error_log] if options[:error_log]
      vh.set :access_log, options[:access_log] if options[:access_log]

      data = @@nginx.build_vh vh

      begin
        File.open(vhost_path, "w") {|f| f.write(data) }
      rescue StandardError => bang
        puts "Error attempting to create virtual host"+ bang.to_s
        return
      end

      puts "Virtualhost #{name} created, would you like to enable it?"
      printf "Press 'y' to continue: "
      prompt = STDIN.gets.chomp
      return unless prompt == 'y'

      self.enable name
      self.reload
    end

    desc "view <name>", "Displays the content of a virtualhost"
    def view(name)
      unless File.exist? File.join(@@nginx.vh_available_directory, name)
        puts "Virtualhost #{name} does not exist"
        return
      end

      system "cat", File.join(@@nginx.vh_available_directory, name)
    end

    desc "edit <name>", "Edits with nano the content of a virtualhost"
    option :vim, :banner => "VIM", :type => :boolean, :aliases => "-v", :desc => "Uses vim for editing"
    def edit(name)
      unless File.exist? File.join(@@nginx.vh_available_directory, name)
        puts "Virtualhost #{name} does not exist"
        return
      end

      editor = "nano"
      if options[:vim]
        editor = "vi"
      end

      system editor, File.join(@@nginx.vh_available_directory, name)
    end

    desc "list", "List all your available virtualhosts"
    def list
      rows = []
      rows << ["Enabled", "Location", "Name"]

      Dir.chdir(@@nginx.vh_available_directory) do
        Dir.glob("*").each do |file|
          if File.exist?(File.join(@@nginx.vh_enabled_directory, file))
            rows << ["*", @@nginx.vh_available_directory, file]
          else
            rows << ["", @@nginx.vh_available_directory,file]
          end
        end

        puts Terminal::Table.new :rows => rows
      end

    end

    desc "enable <name>", "Enable a virtual host"
    def enable(name)
      path = File.join(@@nginx.vh_available_directory, name)
      path_enabled = File.join(@@nginx.vh_enabled_directory, name)

      unless File.exist? path
        puts "Virtual host #{name} does not exist"
        return
      end

      if File.exist? path_enabled
        puts "Virtual host #{name} already enabled"
        return
      end

      begin
        File.symlink path, path_enabled
        puts "Virtual host #{name} enabled successfully"
      rescue StandardError => bang
        puts "Error enabling virtual host: " + bang.to_s
      end
    end

    desc "disable <name>", "Disables a virtual host"
    def disable(name)
      path = File.join(@@nginx.vh_enabled_directory, name)

      unless File.exist? path
        puts "Virtual host #{name} is not enabled."
        return
      end

      begin
        File.unlink path
        puts "Virtual host #{name} disabled successfully"
      rescue StandardError => bang
        puts "Error disabling virtual host: " + bang.to_s
      end
    end

    desc "delete <name>", "Deletes a virtual host"
    def delete(name)
      path = File.join(@@nginx.vh_available_directory, name)

      unless File.exist? path
        puts "Virtual host #{name} does not exists"
        return
      end

      puts "Virtualhost #{name} will be deleted, would you like to continue?"
      printf "Press 'y' to continue: "
      prompt = STDIN.gets.chomp
      return unless prompt == 'y'

      puts "Disabling the virtualhost..."
      disable name

      begin
        File.unlink path
        puts "Virtual host #{name} deleted successfully, would you like to reload nginx?"
        printf "Press 'y' to continue: "
        prompt = STDIN.gets.chomp
        return unless prompt == 'y'

        reload
      rescue StandardError => bang
        puts "Error deleting virtual host: " + bang.to_s
      end
    end

    desc "path <name>", "Returns the path to a virtual host"
    def path(name)
      path = File.join(@@nginx.vh_available_directory, name)

      unless File.exist? path
        puts "Virtual host #{name} does not exist"
        return
      end

      puts path
    end

      desc "reload", "Reload the virtualhosts into the server"
    def reload
      puts "Attempting to reload nginx..."
      begin
        system "service", @@nginx.service_name, "reload"
        puts "nginx reloaded successfully"
      rescue StandardError => bang
        puts "Error attempting to reload nginx: "+ bang.to_s
      end
    end
  end


end

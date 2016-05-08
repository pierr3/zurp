require_relative "serverconfiguration"
require File.join(Gem.datadir("zurp"), "nginx", "nginx")

module Zurp
  class Nginx

    def initialize
      # We assume nginx config file can be in /etc/nginx or /usr/local/nginx
      for path in NginxConfig.get :directories
        if File.exist? File.join(path, "nginx.conf")
          @working_dir = path
          break
        end
      end

      unless @working_dir
        raise 'Could not find nginx configuration folder'
      end

    end

    def directory
      @working_dir
    end

    def www_directory
      File.join(@working_dir, NginxConfig.get(:www_directory))
    end

    def php_fpm
      NginxConfig.get :php_fpm
    end

    def vh_enabled_directory
      File.join(@working_dir, NginxConfig.get(:vh_enabled_directory))
    end

    def vh_available_directory
      File.join(@working_dir, NginxConfig.get(:vh_available_directory))
    end

    def service_name
      NginxConfig.get :service_name
    end

    def build_vh(vhdata)
      arguments = ""

      vhdata.raw.each do |key,value|
        if key.to_s.start_with? "_"
          next
        end

        endln = value.to_s.end_with?("}") ? "": ";"
        endln = value.to_s.end_with?("\n") ? "" : ";"

        arguments << "  " << key.to_s << " " << value.to_s << endln << "\n"

      end

      vh = vhdata.get(:_template).gsub("#data#", arguments)
      vh
    end
  end
end
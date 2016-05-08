class NginxConfig < ServerConfiguration
  set :directories, [File.join("/", "etc", "nginx"),
                     File.join("/", "usr", "share", "nginx"),
                     File.join("/", "opt", "nginx")]
  set :www_directory, "www"
  set :vh_available_directory, "sites-available"
  set :vh_enabled_directory, "sites-enabled"

  set :service_name, "nginx"
  set :php_fpm, "unix:/var/run/php5-fpm.sock"
end
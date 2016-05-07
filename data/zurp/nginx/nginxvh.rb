class NginxVirtualHost < VirtualHost
  set :_template, <<-EOF
server {
#data#
}
  EOF

  set :listen, 80

  set :server_name, "example.org"
  set :root, ""
  set :index, "index.html index.htm"

  def self.passenger(startup_file = nil)
    set :passenger_enabled, "on"
    if startup_file
      if startup_file.end_with? ".js"
        set :passenger_app_type, "node"
      end
      set :passenger_startup_file, startup_file
    end

    unless get(:root).end_with? "public"
      set :root, File.join(get(:root), "public")
    end
    delete :index
  end

  def self.port(port)
    set :_port, port

    set :listen, port
  end

  def self.laravel(path)
    self.php(path)

    unless get(:root).end_with? "public"
      set :root, File.join(get(:root), "public")
    end

    set "location /", <<-EOF
{
     try_files $uri $uri/ /index.php$is_args$args;
}
    EOF
  end

  def self.php(path)
    set "location /", <<-EOF
{
     try_files $uri $uri/ /index.html;
}
    EOF

    set "location ~ \.php$ ", <<-EOF
{
        try_files $uri /index.php =404;
        fastcgi_pass #{path};
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
}
    EOF

    set :index, "index.php index.html index.htm"

  end

  def self.ssl(cert, key)
    set :ssl, "on"
    set :ssl_certificate, cert
    set :ssl_certificate_key, key

    set :listen, 443
  end

  def self.ipv6 (only = false)
    port = get(:ssl).equal?("on") ? "443" : "80"
    port = get :_port if get :_port
    if only
      set :listen, "[::]:#{port} default ipv6only=on"
    else
      set :listen, "[::]:#{port}"
    end
  end

end
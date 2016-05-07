# Zurp

Zurp allows your to quickly enable, disable, delete and create nginx virtualhosts,
with templates for passenger virtualhosts (ruby, python, nodejs), php, laravel and ssl.

## Installation
    $ gem install zurp

## Usage

```
Commands:
  zurp datadir            # Returns the path to the data directory of the gem
  zurp delete <name>      # Deletes a virtual host
  zurp disable <name>     # Disables a virtual host
  zurp edit <name>        # Edits with nano the content of a virtualhost
  zurp enable <name>      # Enable a virtual host
  zurp help [COMMAND]     # Describe available commands or one specific command
  zurp list               # List all your available virtualhosts
  zurp new <name> <host>  # Creates a new virtual host
  zurp path <name>        # Returns the path to a virtual host
  zurp reload             # Reload the virtualhosts into the server
  zurp view <name>        # Displays the content of a virtualhost
```

The new command is a bit more complex:

```
Usage:
  zurp new <name> <host>

Options:
  -r, [--root=ROOT]                                    # Specify the root for the virtual host
  (defaults to nginx dir / www / <vhost name>, if using passenger or laravel, "/public" is automatically appended to
  the user select root folder if it wasn't already there)
  -p, [--port=PORT]                                    # Specify the port of the vhost
  (defaults to 80 for http, 443 for https)
  -s, [--ssl=SSL], [--no-ssl]                          # Enables SSL for the virtual host
  -c, [--ssl-cert=SSLCERT]                             # Path to the SSL certificate
  -k, [--ssl-key=SSLKEY]                               # Path to the SSL private key
  -a, [--passenger=PASSENGER], [--no-passenger]        # Enables passenger for the virtual host
  -f, [--passenger-startup-file=PASSENGERSTARTUPFILE]  # Path to the passenger start up file
  (If that file is .js file, the application type will be automatically set for passenger)
  -h, [--php=PHP], [--no-php]                          # Enables PHP with php-fpm for the virtual host
  -l, [--laravel=LARAVEL], [--no-laravel]              # Enables PHP with laravel support
  -j, [--php-socket=PHP]                               # Specifies the php-fpm socket address
  -e, [--error-log=ERRORLOG]                           # Specifies error log file
  -x, [--access-log=ACCESSLOG]                         # Specifies the access log file
      [--ipv6], [--no-ipv6]
      (By default, the vhost only listens on ipv4)
      [--ipv6only], [--no-ipv6only]
```

### Editing the default configuration for nginx

Zurp uses a .rb file to configure certain options for nginx and php-fpm, you can modify this file on your local system
if for instance zurb can't find your nginx installation.
Find the location of this file by running

    $ zurp datadir

Edit the file called nginx.rb.

### Troubleshooting

 * Make sure you zurp has the necessary permissions to edit the nginx files
 * For a quick fix, run zurp with rvmsudo
 * The command `zurp disable <name>` deletes the symlink in "sites-enabled", so make sure you don't store your actual
 virtual host there, or it will be delete running this command with it's name

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pierr3/zurp. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


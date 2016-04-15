# Compute hostname and port from the hostname in the Settings.
# If no hostname is specified, read the hostname from the OS.
module Hostname
  def self.fqdn
    hostname = Settings.hostname.split(':').first if Settings.hostname
    if hostname == 'localhost' || (hostname && hostname.include?('.'))
      hostname
    else
      begin
        Addrinfo.tcp(Socket.gethostname, 0).getnameinfo.first
      rescue ::SocketError => e
        message = <<-MSG.strip_heredoc
          Could not automatically determine the hostname:
          #{e.class}: #{e.message}

          Please set the hostname manually in the configuration
          or consult the documentation of `gethostname`:
           * http://ruby-doc.org/stdlib/libdoc/socket/rdoc/Socket.html#method-c-gethostname
           * man gethostname
           * http://linux.die.net/man/2/gethostname
        MSG
        $stderr.puts message
        exit
      end
    end
  end

  def self.port
    Settings.hostname.split(':').last if Settings.hostname.include?(':')
  end

  def self.url_authority(scheme: 'http')
    port = Ontohub::Application.config.port
    port = ":#{port}" if port
    "#{scheme}://#{Ontohub::Application.config.fqdn}#{port}"
  end
end

Ontohub::Application.config.fqdn = Hostname.fqdn
Ontohub::Application.config.port = Hostname.port
Ontohub::Application.routes.default_url_options[:host] = Hostname.fqdn
if Hostname.port
  Ontohub::Application.routes.default_url_options[:host] << ":#{Hostname.port}"
end

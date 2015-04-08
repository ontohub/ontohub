# Compute hostname and port from the hostname in the Settings.
# If no hostname is specified, read the hostname from the OS.
module Hostname
  def self.fqdn
    hostname = Settings.hostname.split(':').first if Settings.hostname
    if hostname == 'localhost' || (hostname && hostname.include?('.'))
      hostname
    else
      Addrinfo.tcp(Socket.gethostname, 0).getnameinfo.first
    end
  end

  def self.port
    Settings.hostname.split(':').last if Settings.hostname
  end
end

Ontohub::Application.config.fqdn = Hostname.fqdn
Ontohub::Application.config.port = Hostname.port

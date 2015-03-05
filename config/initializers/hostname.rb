# Compute hostname and port from the hostname in the Settings
module Hostname
  def self.fqdn
    hostname = Settings.hostname.split(':').first
    if hostname == 'localhost' || hostname.include?('.')
      hostname
    else
      Addrinfo.tcp(tmp, 0).getnameinfo.first
    end
  end

  def self.port
    Settings.hostname.split(':').last
  end
end

Ontohub::Application.config.fqdn = Hostname.fqdn
Ontohub::Application.config.port = Hostname.port

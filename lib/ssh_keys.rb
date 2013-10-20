require 'tempfile'

# Manages the keys in ~/.ssh/authorized_keys
class SshKeys

  attr_accessor :auth_file

  def initialize(auth_file=nil)
    @auth_file = auth_file || "#{ENV['HOME']}/.ssh/authorized_keys"
  end

  def add_key(key_id, key)
    File.open(auth_file, "a+") do |f|
      f.puts "command=\"#{Rails.root}/bin/git-shell #{key_id}\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty #{key}"
    end
  end

  def remove_key(key_id)
    if File.exists?(auth_file)
      Subprocess.run 'sed', '-i', "/shell #{key_id}\"/d", auth_file
    end
  end

  def refresh_key(key_id, key)
    remove_key key_id
    add_key    key_id, key
  end

end

require 'tempfile'

# Manages the keys in ~/.ssh/authorized_keys
class SshKeys

  attr_accessor :auth_file

  def initialize(auth_file)
    @auth_file = auth_file
  end

  def add_key(key_id, key)
    system "echo 'command=\"#{Rails.root}/bin/git-shell #{key_id}\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty #{key}' >> #{auth_file}"
  end

  def rm_key(key_id)
    system "sed -i.#{key_id} '/shell #{key_id}\"/d' #{auth_file}"
  end

  def refresh_key(key_id, key)
    rm_key key_id
    add_key key_id, key
  end

end

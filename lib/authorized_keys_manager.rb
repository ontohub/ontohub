require 'pathname'

class AuthorizedKeysManager

  CONFIG               = Ontohub::Application.config
  GIT_HOME             = Pathname.new(CONFIG.git_home)
  SSH_DIR              = GIT_HOME.join('.ssh')
  AUTHORIZED_KEYS_FILE = SSH_DIR.join('authorized_keys')
  GIT_SHELL_FILE       = Rails.root.join('git', 'bin', 'git-shell')

  class << self
    def add(key_id, key)
      key_line = build_key_line(key_id, key)
      File.open(AUTHORIZED_KEYS_FILE, 'a') { |f| f.write(key_line) }
    end

    def remove(key_id)
      return if AUTHORIZED_KEYS_FILE.exist?

      lines = File.readlines(AUTHORIZED_KEYS_FILE)
      File.open(AUTHORIZED_KEYS_FILE, 'w') do |f|
        lines.each { |line| is?(line, key_id) ? nil : f.write(line) }
      end

    end

    def build_key_line(key_id, key)
      cmd = <<-KEY
        command=\"#{GIT_SHELL_FILE} #{key_id}\",
        no-port-forwarding,no-x11-forwarding,
        no-agent-forwarding,no-pty #{key}
      KEY
      cmd.gsub("\n",'').gsub(/\s+/,' ') + "\n"
    end

    private
    def is?(line, key_id)
      !! line.match(/#{key_id},/)
    end

  end

end

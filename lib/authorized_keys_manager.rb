class AuthorizedKeysManager

  Config               = Ontohub::Application.config
  GIT_HOME             = Config.git_home
  SSH_DIR              = GIT_HOME.join('.ssh')
  AUTHORIZED_KEYS_FILE = SSH_DIR.join('authorized_keys')
  GIT_SHELL_FILE       = Rails.root.join('git', 'bin', 'git-shell')

  class << self
    def add(key_id, key)
      ensure_existence
      key_line = build_key_line(key_id, key)
      File.open(AUTHORIZED_KEYS_FILE, 'a') { |f| f.write(key_line) }
    end

    def remove(key_id)
      ensure_existence
      lines = File.new(AUTHORIZED_KEYS_FILE).try(:readlines) || []
      File.open(AUTHORIZED_KEYS_FILE, 'r') do |f|
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

    def ensure_existence
      SSH_DIR.mkpath
      FileUtils.touch(AUTHORIZED_KEYS_FILE)
      ensure_permissions if Config.git_user
    end

    def ensure_permissions
      FileUtils.chmod(0600, AUTHORIZED_KEYS_FILE)
      usergroup = [Config.git_user, Config.git_group].compact.join(':')
      system("chown -R #{Config.git_user} #{Config.git_home}")
    end

  end

end

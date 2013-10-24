class AuthorizedKeysManager

  GIT_HOME = Ontohub::Application.config.git_home
  GIT_USER = Ontohub::Application.config.git_user
  GIT_GROUP = Ontohub::Application.config.git_group
  GIT_SHELL_FILE = File.join(Rails.root, 'git', 'bin', 'git-shell')
  AUTHORIZED_KEYS_FILE = File.join(GIT_HOME, '.ssh', 'authorized_keys')

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
      FileUtils.mkdir_p(File.dirname(AUTHORIZED_KEYS_FILE))
      FileUtils.touch(AUTHORIZED_KEYS_FILE)
      ensure_permissions
    end

    def ensure_permissions
      FileUtils.chmod(0600, AUTHORIZED_KEYS_FILE)
      usergroup = [GIT_USER, GIT_GROUP].compact.join(':')
      system("chown -R #{usergroup} #{GIT_HOME}")
    end

  end

end

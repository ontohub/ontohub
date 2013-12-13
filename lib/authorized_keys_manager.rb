require 'pathname'

class AuthorizedKeysManager

  CONFIG               = Ontohub::Application.config
  GIT_HOME             = Pathname.new(CONFIG.git_home)
  SSH_DIR              = GIT_HOME.join('.ssh')
  AUTHORIZED_KEYS_FILE = SSH_DIR.join('authorized_keys')
  GIT_SHELL_FILE       = Rails.root.join('git', 'bin', 'git-shell').
    # replace capistrano-style release with 'current'-symlink
    sub(%r{/releases/\d+/}, '/current/')

  # make sure ssh-dir exists.
  SSH_DIR.mkpath

  class << self
    def add(key_id, key)
      in_authorized_keys('a') do |f|
        f << build_key_line(key_id, key)
      end
    end

    def remove(key_id)
      return if !AUTHORIZED_KEYS_FILE.exist?

      in_authorized_keys('r+') do |f|
        lines = []
        f.each_line { |l| lines << l }
        f.rewind
        lines.each { |line| f << line if is?(line, key_id) }
        f.truncate(f.pos)
      end

    end

    def build_key_line(key_id, key)
      cmd = "command=\"#{GIT_SHELL_FILE} #{key_id}\","+
        %w{
          no-port-forwarding
          no-x11-forwarding
          no-agent-forwarding
          no-pty
        }.join(',') + " #{key}\n"
    end

    private

    def is?(line, key_id)
      line.include? " #{key_id}\","
    end

    def in_authorized_keys(mode)
      File.open(AUTHORIZED_KEYS_FILE, mode) do |file|
        file.flock(File::LOCK_EX)
        yield file
      end
    end

  end

end

require 'pathname'

class AuthorizedKeysManager
  GIT_SHELL_FILE = Rails.root.join('git', 'bin', 'git-shell').
    # replace capistrano-style release with 'current'-symlink
    sub(%r{/releases/\d+/}, '/current/')

  class << self
    def ssh_dir
      Ontohub::Application.config.data_root.join('.ssh')
    end

    def authorized_keys_file
      ssh_dir.join('authorized_keys')
    end

    # This must be defined in two places. Make sure this value is synchronized
    # with SettingsValidationWrapper#cp_keys.
    def cp_keys_executable
      ssh_dir.join('cp_keys')
    end

    def add(key_id, key)
      in_authorized_keys('a') do |f|
        f << build_key_line(key_id, key)
      end
    end

    def remove(key_id)
      return if !authorized_keys_file.exist?

      in_authorized_keys('r+') do |f|
        lines = []
        f.each_line { |l| lines << l }
        f.rewind
        lines.each { |line| f << line unless is?(line, key_id) }
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
      ssh_dir.mkpath
      File.open(authorized_keys_file, mode) do |file|
        file.flock(File::LOCK_EX)
        yield file
      end
      copy_authorized_keys_to_git_home
    end

    def copy_authorized_keys_to_git_home
      system(cp_keys_executable.to_s)
    end
  end
end

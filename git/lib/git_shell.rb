require 'open3'

class GitShell
  attr_accessor :key_id, :repo_name, :git_cmd, :repos_path

  GIT_CMDS = %w( git-upload-pack git-receive-pack git-upload-archive )

  def initialize(key_id, command)
    @key_id     = key_id
    @command    = command
    @repos_path = File.join(Settings.git_home, 'repositories')
  end

  def exec
    if Settings.data_root.join("maintenance.txt").exist?
      STDERR.puts "System in maintenance mode. Please try again later."
      exit 1
    end

    exit 1 unless @command
    
    parse_cmd

    if GIT_CMDS.include?(@git_cmd)
      # required to pass the ID to the update hook
      ENV['KEY_ID'] = @key_id

      if validate_access
        process_cmd
      else
        message = "git-shell: Access denied for git command <#{@command}> by #{log_username}."
        Rails.logger.warn message
        STDERR.puts <<-MSG
Access denied.
Please take a look at
http://wiki.ontohub.org/index.php/Permission
for more information about permissions."
        MSG
      end
    else
      message = "git-shell: Attempt to execute disallowed command <#{@command}> by #{log_username}."
      Rails.logger.warn message
      STDERR.puts 'Not allowed command'
    end
  end

  protected

  def parse_cmd
    @git_cmd, @repo_name = @command.split(' ')
  end

  def process_cmd
    repo_full_path = File.join(repos_path, repo_name)
    cmd = "#{@git_cmd} #{repo_full_path}"
    Rails.logger.info "git-shell: executing git command <#{cmd}> for #{log_username}."
    exec_cmd(cmd)
  end

  def validate_access
    api.allowed?(@git_cmd, @repo_name, @key_id, '_any')
  end

  def exec_cmd(cmd)
    Kernel::exec(cmd)
  end

  def api
    OntohubNet.new
  end

  def log_username
    "user with key #{@key_id}"
  end
end

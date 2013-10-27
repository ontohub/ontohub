require 'open3'

class GitShell
  attr_accessor :key_id, :repo_name, :git_cmd, :repos_path

  GIT_CMDS = %w( git-upload-pack git-receive-pack git-upload-archive )

  def initialize(key_id, command)
    @key_id  = key_id
    @command = command

    @config     = OntohubConfig.instance
    @repos_path = @config.repos_path
  end

  def exec
    if @command
      parse_cmd

      if GIT_CMDS.include?(@git_cmd)
        ENV['KEY_ID'] = @key_id

        if validate_access
          process_cmd
        else
          message = "git-shell: Access denied for git command <#{@command}> by #{log_username}."
          $logger.warn message
          $stderr.puts "Access denied."
        end
      else
        message = "git-shell: Attempt to execute disallowed command <#{@command}> by #{log_username}."
        $logger.warn message
        puts 'Not allowed command'
      end
    else
      exit(1)
    end
  end

  protected

  def parse_cmd
    @git_cmd, @repo_name = @command.split(' ')
  end

  def process_cmd
    repo_full_path = File.join(repos_path, repo_name)
    cmd = "#{@git_cmd} #{repo_full_path}"
    $logger.info "git-shell: executing git command <#{cmd}> for #{log_username}."
    exec_cmd(cmd)
  end

  def validate_access
    api.allowed?(@git_cmd, @repo_name, @key_id, '_any')
  end

  def exec_cmd args
    Kernel::exec args
  end

  def api
    OntohubNet.new
  end

  def user
    # Can't use "@user ||=" because that will keep hitting the API when @user is really nil!
    if instance_variable_defined?("@user")
      @user
    else
      @user ||= api.discover(@key_id)
    end
  end

  def username
    user && user['name'] || 'Anonymous'
  end

  # User identifier to be used in log messages.
  def log_username
    @config.audit_usernames ? username : "user with key #{@key_id}"
  end
end

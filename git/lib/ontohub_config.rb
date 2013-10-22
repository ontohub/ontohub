require 'yaml'
require 'singleton'

class OntohubConfig
  include Singleton

  attr_reader :config

  def initialize
    @config = {} #YAML.load_file(File.join(ROOT_PATH, 'config.yml'))
  end

  def git_user
    @config['git_user'] ||= "git"
  end

  def git_home
    @config['git_home'] ||= "/home/#{git_user}"
  end

  def repos_path
    @config['repos_path'] ||= "#{git_home}/repositories"
  end

  def auth_file
    @config['auth_file'] ||= "#{git_home}/.ssh/authorized_keys"
  end

  def ontohub_url
    @config['ontohub_url'] ||= "http://localhost/"
  end

  def http_settings
    @config['http_settings'] ||= {}
  end

  def redis
    @config['redis'] ||= {}
  end

  def redis_namespace
    redis['namespace'] || 'ontohub'
  end

  def log_file
    @config['log_file'] ||= File.join(ROOT_PATH, '../log/git.log')
  end

  def log_level
    @config['log_level'] ||= 'INFO'
  end

  def audit_usernames
    @config['audit_usernames'] ||= false
  end

  # Build redis command to write update event in ontohub queue
  def redis_command
    if redis.empty?
      # Default to old method of connecting to redis
      # for users that haven't updated their configuration
      "env -i redis-cli"
    else
      if redis.has_key?("socket")
        "#{redis['bin']} -s #{redis['socket']}"
      else
        "#{redis['bin']} -h #{redis['host']} -p #{redis['port']}"
      end
    end
  end
end

require 'json'
require File.join(File.expand_path('../../../lib', __FILE__), 'subprocess')
require 'ontohub_net'

class GitUpdate

  def initialize(repo_path, key_id, refs)
    @repo_path = repo_path.strip
    @repo_name = repo_path.sub(Settings.git_root.to_s, '').
      gsub(/\.git$/, "").
      gsub(/^\//, "")

    @refname = refs[0]
    @oldrev  = refs[1]
    @newrev  = refs[2]

    @key_id = key_id
    @branch_name = /refs\/heads\/([\w\.-]+)/.match(@refname).to_a.last
  end

  def exec
    # If its push over ssh
    # we need to check user persmission per branch first
    if ssh?
      if api.allowed?('git-receive-pack', @repo_name, @key_id, @branch_name)
        update_redis
        exit 0
      else
        puts "Git: You are not allowed to access #{@branch_name}!"
        exit 1
      end
    else
      update_redis
      exit 0
    end
  end

  protected

  def api
    OntohubNet.new
  end

  def ssh?
    @key_id =~ /\Akey\-\d+\Z/
  end

  def update_redis
    Subprocess.run 'redis-cli', 'rpush', "#{Settings.redis_namespace}:queue:default", {
      class: 'RepositoryUpdateWorker',
      args: [@repo_path, @oldrev, @newrev, @refname, @key_id]
    }.to_json
  end
end

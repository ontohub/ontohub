require 'json'
require File.join(File.expand_path('../../../lib', __FILE__), 'subprocess')
require 'ontohub_net'

class GitUpdate

  def self.update_redis(repo_path, oldrev, newrev, refname, key_id)
    Subprocess.run 'redis-cli', 'rpush', "#{Settings.redis_namespace}:queue:default", {
      class: 'RepositoryUpdateWorker',
      args: [repo_path, oldrev, newrev, refname, key_id]
    }.to_json
  end

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
        exit 0
      else
        STDERR.puts <<-MSG
Git: You are not allowed to access #{@branch_name}!
Please take a look at
http://wiki.ontohub.org/index.php/Permission
for more information about permissions.
        MSG
        exit 1
      end
    else
      exit 0
    end
  rescue OntohubNet::UnexpectedStatusCodeError => error
    STDERR.puts <<-ERROR
We couldn't determine your permissions successfully because
we encountered a status code of #{error.status_code} when
querying for permissions. Please try again in a few minutes.
If this issue persists please inform an Administrator.
    ERROR
    exit 1
  end

  protected

  def api
    OntohubNet.new
  end

  def ssh?
    @key_id =~ /\Akey\-\d+\Z/
  end

end

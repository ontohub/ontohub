require 'subprocess.rb'
require 'singleton'

def init(path)
  FileUtils.mkdir_p(path)
  RepositoryCreator.instance.root_path = path
  FileUtils.rm_rf(Dir.glob(path.join('*')))
end

def repo_clone(*args)
  RepositoryCreator.instance.clone *args
end

def add_url_map(*args)
  RepositoryCreator.instance.url_map(*args)
end

def save_to_ontohub
  RepositoryCreator.instance.save
end


class RepositoryCreator
  include Singleton
  attr_accessor :root_path
  def initialize
    @current_repo = nil
  end

  def clone(name, url)
    @current_repo = Repo.new(name, url)
  end

  def url_map(source, target)
    @current_repo.url_maps << UrlMap.new(source: source, target: target)
  end

  def save
    @current_repo.save
  end
end

class Repo
  attr_accessor :url_maps
  def initialize(name, url=nil)
    @name = name
    @path = RepositoryCreator.instance.root_path.join(name)
    @url_maps = []

    if url
      Subprocess.run 'git', 'clone', url, @path
    else
      Subprocess.run 'git', 'init', @path
    end
  end

  def save
    r = Repository.new name: @name, description: 'Seeded Repository', source_address: @path.to_s, access: 'public_r'
    r.user = User.first
    r.url_maps = @url_maps
    r.save!
    r.async :convert_to_local!
  end
end

# def git_exec(name, *args)
#   args.unshift 'git'
#   args.push \
#     GIT_DIR: NEW_REPOS_ROOT.join(name).to_s,
#     LANG:    'C'
#
#   Subprocess.run *args
# end

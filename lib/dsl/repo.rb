#require 'subprocess.rb'
require 'singleton'

def init(path)
  FileUtils.mkdir_p(path)
  RepositoryCreator.instance.root_path = path
  RepositoryCreator.instance.cleanup
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

  def clone(name, url)
    @current_repo = Repo.new(name, url)
  end

  def url_map(source, target)
    @current_repo.url_maps << UrlMap.new(source: source, target: target)
  end

  def save
    @current_repo.save
  end

  def cleanup
    FileUtils.rm_rf(Dir.glob(root_path.join('*')))
  end
end

class Repo

  attr_accessor :url_maps

  def initialize(name, url=nil)
    @name = name
    @path = url || RepositoryCreator.instance.root_path.join(name)
    @url_maps = []

    unless url
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

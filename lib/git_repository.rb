# Wrapper for access to the local Git repository
class GitRepository

  attr_reader

  def initialize(path)
    if File.exists?(path)
      @repo = Rugged::Repository.new(path)
    else
      @repo = Rugged::Repository.init_at(path, true)
    end
  end

end
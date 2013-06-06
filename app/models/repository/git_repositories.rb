module Repository::GitRepositories
  extend ActiveSupport::Concern
  
  after_create  :git
  after_destroy :destroy_git
  
  def git
    @git ||= GitRepository.new(local_path)
  end

  def local_path
    "#{Ontohub::Application.config.git_root}/#{id}"
  end
  
  def destroy_git
    FileUtils.rmtree local_path
  end
  
end
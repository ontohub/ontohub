
module PathsInitializer

  class << self
    def perform_initialization(config)
      config.data_root = Rails.root.join(Settings.paths.data).
        sub(%r(/releases/\d+/), "/current/")

      config.git_root = Rails.root.join(Settings.paths.git_repositories)
      config.symlink_path = Rails.root.join(Settings.paths.symlinks)
      config.commits_path = Rails.root.join(Settings.paths.commits)

      settings = Settings.git
      if settings && settings.user
        config.git_user  = settings.user
        config.git_group = settings.group
        config.git_home  = File.expand_path("~#{config.git_user}")
      else
        config.git_user  = nil
        config.git_group = nil
        config.git_home  = Rails.root.join('tmp','git')
      end
    end
  end

end

if defined?(Ontohub::Application)
  Ontohub::Application.configure do |app|
    PathsInitializer.perform_initialization(app.config)
  end
end


module PathsInitializer
  class << self
    def cleanup_release(path)
      path.sub(%r(/releases/\d+/), "/current/")
    end

    def perform_initialization(config)
      config.data_root = cleanup_release(Rails.root.join(Settings.paths.data))

      config.git_root =
        cleanup_release(Rails.root.join(Settings.paths.git_repositories))

      config.symlink_path =
        cleanup_release(Rails.root.join(Settings.paths.symlinks))

      config.commits_path =
        cleanup_release(Rails.root.join(Settings.paths.commits))

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

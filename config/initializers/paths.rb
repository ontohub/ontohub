
module PathsInitializer
  class << self
    def cleanup_release(path)
      path.sub(%r(/releases/\d+/), "/current/")
    end

    def perform_initialization(config)
      config.data_root = cleanup_release(Rails.root.join(Settings.paths.data))

      config.git_root =
        cleanup_release(Rails.root.join(Settings.paths.git_repositories))

      config.git_home =
        cleanup_release(Rails.root.join(Settings.paths.git_home))

      config.symlink_path =
        cleanup_release(Rails.root.join(Settings.paths.symlinks))

      config.commits_path =
        cleanup_release(Rails.root.join(Settings.paths.commits))
    end
  end
end

if defined?(Ontohub::Application)
  Ontohub::Application.configure do |app|
    PathsInitializer.perform_initialization(app.config)
  end
end

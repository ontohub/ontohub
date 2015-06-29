module PathsInitializer
  class << self
    def expand(path)
      Dir.chdir(Rails.root) { Pathname.new(path).expand_path }
    end

    def cleanup_release(path)
      path.sub(%r(/releases/\d+/), "/current/")
    end

    # Only defines methods to prevent NoMethodErrors
    # To be called before settings validation.
    def empty_initialization(config)
      config.data_root = nil
      config.git_root = nil
      config.git_home = nil
      config.symlink_path = nil
      config.commits_path = nil
    end

    # Actually performs initialization
    # To be called after settings validation
    def perform_initialization(config)
      config.data_root = cleanup_release(expand(Settings.paths.data))
      config.git_root = cleanup_release(expand(Settings.paths.git_repositories))
      config.git_home = cleanup_release(expand(Settings.paths.git_home))
      config.symlink_path = cleanup_release(expand(Settings.paths.symlinks))
      config.commits_path = cleanup_release(expand(Settings.paths.commits))
    end
  end
end

if defined?(Ontohub::Application)
  Ontohub::Application.configure do |app|
    PathsInitializer.empty_initialization(app.config)
  end
end

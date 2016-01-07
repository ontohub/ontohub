module PathsInitializer
  DEFAULT_PATHS = {git_repositories: 'repositories',
                   git_deamon: 'git_daemon',
                   commits: 'commits'}
  class << self
    def expand(path)
      Dir.chdir(Rails.root) { Pathname.new(path).expand_path }
    end

    def cleanup_release(path)
      path.sub(%r(/releases/\d+/), "/current/")
    end

    def prepare(path, fallback = nil)
      path = File.join(Settings.paths.data, fallback) if fallback && path.nil?
      cleanup_release(expand(path))
    end

    # Only defines methods to prevent NoMethodErrors
    # To be called before settings validation.
    def empty_initialization(config)
      config.data_root = nil
      config.git_root = nil
      config.git_daemon_path = nil
      config.commits_path = nil
    end

    # Actually performs initialization
    # To be called after settings validation
    def perform_initialization(config)
      config.data_root = prepare(Settings.paths.data)
      config.git_root = prepare(Settings.paths.git_repositories, DEFAULT_PATHS[:git_repositories])
      config.git_daemon_path = prepare(Settings.paths.git_daemon, DEFAULT_PATHS[:git_daemon])
      config.commits_path = prepare(Settings.paths.commits, DEFAULT_PATHS[:commits])
    end
  end
end

if defined?(Ontohub::Application)
  Ontohub::Application.configure do |app|
    PathsInitializer.empty_initialization(app.config)
  end
end

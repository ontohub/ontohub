
module PathsInitializer

  class << self
    def perform_initialization(config)
      settings = Rails.env == "test" ? nil : Settings.git
      config.data_root = (settings && settings.data_dir) \
        ? Pathname.new(settings.data_dir)
        : Rails.root.join('tmp','data')

      config.git_root     = config.data_root.join('repositories')
      config.symlink_path = config.data_root.join('git_daemon')
      config.commits_path = config.data_root.join('commits')
    end
  end

end

if defined?(Ontohub::Application)
  Ontohub::Application.configure do |app|
    PathsInitializer.perform_initialization(app.config)
  end
end


module PathsInitializer

  class << self
    def perform_initialization(config)
      if Rails.env == "test"
        config.data_root = Rails.root.join('tmp','data')
      else
        config.data_root = Rails.root.join('data').sub(%r(/releases/\d+/), "/current/")
      end

      config.git_root = config.data_root.join('repositories')
      config.git_working_copies_root = config.data_root.join('working_copies')
      config.max_read_filesize = 512 * 1024

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

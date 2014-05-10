module LimitsInitializer

  class << self
    def perform_initialization(config)
      config.max_read_filesize = 512 * 1024
      config.max_combined_diff_size = 1024 * 1024
    end
  end

end

if defined?(Ontohub::Application)
  Ontohub::Application.configure do |app|
    LimitsInitializer.perform_initialization(app.config)
  end
end

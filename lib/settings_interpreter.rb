class SettingsInterpreter
  def call
    if defined?(Ontohub::Application)
      Ontohub::Application.configure do |app|
        PathsInitializer.perform_initialization(app.config)
      end
    end
  end
end

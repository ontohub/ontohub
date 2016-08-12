unless defined?(Rails)
  rails_root = File.join(File.dirname(__FILE__), '..')
  require File.join(rails_root, 'lib', 'environment_light.rb')
  Settings.add_source!(File.join(rails_root, 'config', 'hets.yml'))
  Settings.reload!
end

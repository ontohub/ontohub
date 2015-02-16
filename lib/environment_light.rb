require File.expand_path('../../config/boot', __FILE__)
require 'rails_config'

# Module to extent RailsConfig with some convinience methods.
# Requires rails_config >= 5.0.0.beta1 !
module AppConfig
  mattr_accessor :root, :env
  @@initialized = false

  # Initialize and freeze. Sets the variables @@root (the application's base
  # directory) as well as @@env (the rails environment name). If ::Rails is
  # defined, i.e. this ethod gets called within a rails application, the
  # values from Rails.root and Rails.env will be used if not empty.
  # Otherwiss @@envc gets set to the value of the RAILS_ENV variable if set,
  # otherwise to 'production'. Finally this module gets frozen to keep these
  # values unchanged.
  #
  # There is usually no need to explicitly call this method - it gets called
  # automatically when needed. However, calling more than once does'nt hurt.
  def self.init
    if @@initialized
      return
    end
    # if ::Rails is already defined, its values take precedence
    if Object.const_defined?('Rails')
      e = Rails.env
      r = Rails.root
    end
    @@root = r || File.expand_path('../..', __FILE__)
    @@env = ENV['RAILS_ENV'] || 'production'
    if @@env.length < 1
      @@env = 'production'
    end
    @@initialized = true
    self.freeze
  end

  # Set the name of the global Object to use for all further AppConfig as well
  # as RailsConfig operations.
  #
  # @param [String] name  The name to set. If nil or empty, the default will
  #   be used.
  # @return [String] The name of the global object previously used.
    def self.setName(name='Settings')
    old = RailsConfig.const_name
    RailsConfig.const_name = name && name.length > 0 ? name : 'Settings'
    old
    end

  # Get the name of the global object, which is currently used for AppConfig
  # as well as RailsConfig operations.
  #
  # @return [String] the name of the global object to use.
  def self.getName
    RailsConfig.const_name
  end

  # Load YAMLed application settings into the global RailsConfig::Options
  # object named "#{RailsConfig.const_name}" (default: Settings). If the
  # object is already defined and force is set to false, this method just
  # returns false, i.e. it does not overwrite the current settings. Otherwise
  # sfiles and the defaults (see RailsConfig::setting_files(@@root,@@env))
  # gets loaded in exactly the specified order and put into the given object.
  # Non-existent files get silently ignored.
  #
  # @example Initialize 'Settings' exactly as it is done within rails
  #   AppConfig::load
  # @example Same as above, but reload/generate only if it is not yet defined.
  #   AppConfig::load(false)
  # @example Load the file 'config/myapp.yml' before the default settings
  #   files and store the resulting config in 'MyConf'
  #   require 'rails_config'
  #   old = AppConfig::setName('MyConf')   # save to "avoid" bad side effects
  #   AppConfig::load(true, 'config/myapp.yml')
  #   AppConfig::setName(old)              # restore to avoid side effects
  #
  # @param [Boolean] force  If false neither load the related sources nor
  #   reinitialize the related global RailsConfig::Options object if it is
  #   already defined. Otherwise load and create a new related global object.
  # @param [Array<#to_s]>] sfiles  Files to load first. Relative filenames
  #   are interpreted wrt. @@root, otherwise taken as is. Non-existent files
  #   get silently ignored.
  # @return [true, false] true if a new configuration was created, false
  #   otherwise.
  def self.load(force=true, *sfiles)
    self.init
    if ! force && Object.const_defined?(RailsConfig.const_name)
      return false
    end
    defaults = RailsConfig::setting_files(@@root + '/config', @@env)
    if sfiles
      files = Array.new
      [sfiles].flatten.compact.uniq.each do |file|
        f = file.to_s
        if f[0] != '/'
          f = File.join(@@root, f).to_s
        end
        files << f
      end
      files << defaults
    else
      files = defaults
    end
    RailsConfig::load_and_set_settings(files)
    return true
  end
end

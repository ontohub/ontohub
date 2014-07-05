begin
  require File.expand_path("../../../lib/environment_light", __FILE__)
  require File.expand_path("../../../config/initializers/paths", __FILE__)

  # extend the load path
  $:.unshift File.dirname(__FILE__)
  $:.unshift Rails.root.join("lib")

  require 'logger'

  # Configuration #
  #################

  Settings.redis_namespace = 'ontohub'
  Rails.logger = Logger.new Rails.root.join('log','git.log')
  PathsInitializer.perform_initialization(Settings)

  require 'ontohub_net'
rescue ScriptError => e
  STDERR.puts <<-ERROR
We encountered a hard system error while processing
your git-interaction attempt.
The git command was not processed; your data is safe.
Please contact and inform an administrator of this issue.
  ERROR
  exit 1
end

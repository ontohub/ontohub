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

require File.expand_path(
  File.join(File.dirname(__FILE__), "/../../lib/environment_light"))
require File.expand_path(
  File.join(File.dirname(__FILE__), "/../../config/initializers/paths"))

$:.unshift File.dirname(__FILE__)
$:.unshift Rails.root.join("lib")

require 'logger'

# Configuration #
#################

Settings.redis_namespace = 'ontohub'
Rails.logger = Logger.new Rails.root.join('log','git.log')
PathsInitializer.perform_initialization(Settings)

require 'ontohub_net'

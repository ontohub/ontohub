require File.expand_path(
  File.join(File.dirname(__FILE__), "/../../lib/environment_light"))

$:.unshift File.dirname(__FILE__)
$:.unshift Rails.root.join("lib")

require 'logger'

# Configuration #
#################

Rails.logger = Logger.new Rails.root.join('log','git.log')

require 'ontohub_net'

require File.dirname(__FILE__) << "/../../lib/environment_light"

$:.unshift File.dirname(__FILE__)
$:.unshift Rails.root.join("lib")

require 'ontohub_config'
require 'ontohub_logger'
require 'ontohub_net'

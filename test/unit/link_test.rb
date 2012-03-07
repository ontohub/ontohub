require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  should belong_to :source
  should belong_to :target
end

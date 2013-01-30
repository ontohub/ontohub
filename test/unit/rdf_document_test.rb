require 'test_helper'

# Tests an RDF document
#
# Author: Daniel Couto Vale <danielvale@uni-bremen.de>
#
class RdfDocumentTest < ActiveSupport::TestCase

  context 'Empty Triple List' do
    setup do
      @document = RdfDocument.new([])
    end

    should "expect no domains" do 
      assert_equal [], @document.domains('b','c')
    end

    should "expect no relations" do
      assert_equal [],  @document.relations('a','c')
    end

    should "expect no ranges" do
      assert_equal [], @document.ranges('a','b')
    end
  end

end

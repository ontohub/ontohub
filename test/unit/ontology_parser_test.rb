require 'test_helper'

class OntologyParserTest < ActiveSupport::TestCase

  context "OntologyParser" do

    context 'parsing empty XML' do
      setup do
        @symbols = []
        OntologyParser.parse open_fixture('empty.xml'),
          symbol: Proc.new{ |h| @symbols << h }
      end

      should 'not found any symbols' do
        assert_equal 0, @symbols.count
      end
    end

    context 'parsing invalid XML' do
      should 'not throw an exception' do
        OntologyParser.parse open_fixture('broken.xml'), {}
        assert true
      end
    end

  end

end

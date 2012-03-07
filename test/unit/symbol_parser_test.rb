require 'test_helper'

class SymbolParserTest < ActiveSupport::TestCase
  
  context "SymbolParser" do
    
    context 'parsing valid XML with symbols' do
      setup do
        @logic   = nil
        @symbols = []
        SymbolParser.parse open_fixture('valid.xml'),
          symbols: Proc.new{ |h| @logic = h['logic'] },
          symbol:  Proc.new{ |h| @symbols << h }
      end
      
      should 'find logic' do
        assert_equal 'CASL', @logic
      end
      
      should 'found all symbols' do
        assert_equal 5, @symbols.count
      end
      
      should 'have correct symbols' do
        assert_equal [
          {"name"=>"nat", "range"=>"Examples/Reichel:28.9", "text"=>"sort nat"},
          {"name"=>"__*__", "range"=>"Examples/Reichel:33.11", "text"=>" nat"},
          {"name"=>"__+__", "range"=>"Examples/Reichel:32.11", "text"=>" nat"},
          {"name"=>"succ", "range"=>"Examples/Reichel:30.9", "text"=>" nat"},
          {"name"=>"zero", "range"=>"Examples/Reichel:29.9", "text"=>"op zero : nat"},
        ], @symbols
      end
    end
    
    context 'parsing empty XML' do
      setup do
        @symbols = []
        SymbolParser.parse open_fixture('empty.xml'),
          symbols: Proc.new{ |h| @logic = h['logic'] }
      end
      
      should 'not found any symbols' do
        assert_equal 0, @symbols.count
      end
    end
    
    context 'parsing invalid XML' do
      should 'throw an exception' do
        begin
          SymbolParser.parse open_fixture('broken.xml'), {}
          fail "exception expected"
        rescue SymbolParser::ParseException => e
          assert_equal 'unsupported element: Invalid', e.message
        end
      end
    end
    
  end
  
  def open_fixture(name)
    File.open("#{Rails.root}/test/fixtures/symbols/#{name}")
  end
  
end

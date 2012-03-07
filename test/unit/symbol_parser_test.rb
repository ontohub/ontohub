require 'test_helper'

class SymbolParserTest < ActiveSupport::TestCase
  
  context "SymbolParser" do
    
    context 'parsing valid XML with symbols' do
      setup do
        @logic   = nil
        @symbols = []
        @axioms  = []
        SymbolParser.parse open_fixture('valid.xml'),
          ontology: Proc.new{ |h| @logic = h['logic'] },
          symbol:   Proc.new{ |h| @symbols << h },
          axiom:    Proc.new{ |h| @axioms << h }
      end
      
      should 'find logic' do
        assert_equal 'OWL', @logic
      end
      
      should 'found all symbols' do
        assert_equal 5, @symbols.count
      end
      
      should 'found all axioms' do
        assert_equal 1, @axioms.count
      end
      
      should 'have correct symbols' do
        assert_equal [
          {"name"=>"nat", "range"=>"Examples/Reichel:28.9", "kind" => "sort", "text"=>"nat"},
          {"name"=>"__*__", "range"=>"Examples/Reichel:33.11", "kind" => "op", "text"=>"__*__ : nat * nat -> nat"},
          {"name"=>"__+__", "range"=>"Examples/Reichel:32.11", "kind" => "op", "text"=>"__+__ : nat * nat -> nat"},
          {"name"=>"succ", "range"=>"Examples/Reichel:30.9", "kind" => "op", "text"=>"succ : nat -> nat"},
          {"name"=>"zero", "range"=>"Examples/Reichel:29.9", "kind" => "op", "text"=>"zero : nat"},
        ], @symbols
      end
      
      should 'have correct axioms' do
        assert_equal [{
          "name"=>"... (if exists)",
          "range"=>"Examples/Reichel:40.9",
          "symbols"=>[{"text"=>"nat"}, {"text"=>"succ : nat -> nat"}]
        }], @axioms
      end
    end
    
    context 'parsing empty XML' do
      setup do
        @symbols = []
        SymbolParser.parse open_fixture('empty.xml'),
          symbol: Proc.new{ |h| @symbols << h }
      end
      
      should 'not found any symbols' do
        assert_equal 0, @symbols.count
      end
    end
    
    context 'parsing invalid XML' do
      should 'not throw an exception' do
        SymbolParser.parse open_fixture('broken.xml'), {}
        assert true
      end
    end
    
  end
  
  def open_fixture(name)
    File.open("#{Rails.root}/test/fixtures/symbols/#{name}")
  end
  
end

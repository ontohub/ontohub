require 'test_helper'

class OntologyParser::SimpleTest < ActiveSupport::TestCase
  
  context "OntologyParser" do
    
    context 'parsing simple' do
      setup do
        @ontologies = []
        @symbols    = []
        @axioms     = []
        OntologyParser.parse open_fixture('test1.xml'),
          ontology: Proc.new{ |h| @ontologies << h },
          symbol:   Proc.new{ |h| @symbols << h },
          axiom:    Proc.new{ |h| @axioms << h }
      end
      
      should 'find logic' do
        assert_equal 'CASL', @ontologies.first['logic']
      end
      
      should 'found all symbols' do
        assert_equal 2, @symbols.count
      end
      
      should 'found all axioms' do
        assert_equal 1, @axioms.count
      end
      
      should 'have correct symbols' do
        assert_equal [
          {"name"=>"s", "range"=>"/home/till/CASL/Hets-lib/test/test1.casl:2.8", "kind" => "sort", "text"=>"sort s"},
          {"name"=>"f", "range"=>"/home/till/CASL/Hets-lib/test/test1.casl:3.6", "kind" => "op", "text"=>"op f : s -> s"}
        ], @symbols
      end
      
      should 'have correct axioms' do
        assert_equal [{
          "text" => "forall x : s . f(x) = x %(Ax1)%"
        }], @axioms
      end
    end
    
  end
  
  def open_fixture(name)
    File.open("#{Rails.root}/test/fixtures/ontologies/xml/#{name}")
  end
  
end

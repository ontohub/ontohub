require 'test_helper'

class OntologyParser::ComplexTest < ActiveSupport::TestCase
  
  context "OntologyParser" do
    
    context 'parsing complex XML' do
      setup do
        @ontologies = []
        @symbols    = []
        @axioms     = []
        @links      = []
        OntologyParser.parse open_fixture('test2.xml'),
          ontology: Proc.new{ |h| @ontologies << h },
          symbol:   Proc.new{ |h| @symbols << h },
          axiom:    Proc.new{ |h| @axioms << h },
          link:     Proc.new{ |h| @links << h }
      end
      
      should 'find all ontologies' do
        assert_equal 4, @ontologies.count
      end
      
      should 'found all symbols' do
        assert_equal 3, @symbols.count
      end
      
      should 'found all axioms' do
        assert_equal 2, @axioms.count
      end
      
      should 'found all links' do
        assert_equal 3, @links.count
      end
      
      context 'first link' do
        setup do
          @link = @links.first
        end
        
        should 'have correct source' do
          assert_equal "sp__E1", @link['source']
        end
        
        should 'have correct target' do
          assert_equal "sp__T", @link['target']
        end
      end
      
    end
    
  end
  
  def open_fixture(name)
    File.open("#{Rails.root}/test/fixtures/ontologies/xml/#{name}")
  end
  
end

require 'test_helper'

class AxiomTest < ActiveSupport::TestCase
  context 'Associations' do
    should belong_to :ontology
    should have_and_belong_to_many :entities
  end

  context 'OntologyInstance' do
  	setup do
  		@ontology = Factory :ontology
  	end

  	context 'creating Axioms' do
  		setup do
	  		@axiom_hash = {
	  			'name' => '... (if exists)',
          'range' => 'Examples/Reichel:40.9'
	  		}

	      @ontology.axioms.update_or_create_from_hash @axiom_hash
  		end

  		context 'correct attribute' do
  			setup do
  				@axiom = @ontology.axioms.first
  			end

  			%w[name range].each do |attr|
  				should "be #{attr}" do
  					assert_equal @axiom_hash[attr], eval("@axiom.#{attr}")
  				end
  			end
  		end
  	end
  end

end

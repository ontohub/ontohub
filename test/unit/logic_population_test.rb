require 'test_helper'

# Tests a triple store
#
# Author: Daniel Couto Vale <danielvale@uni-bremen.de>
#
class TripleStoreTest < ActiveSupport::TestCase

  context 'Empty Triple List:' do
    setup do
      @store = TripleStore.new []
      @logicReader = LogicPopulation.new @store;
    end

    should "make empty list" do
      assert_equal [], @logicReader.list
    end
  end

  context 'File Load:' do
    setup do
      type = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
      label = 'http://www.w3.org/2000/01/rdf-schema#label'
      comment = 'http://www.w3.org/2000/01/rdf-schema#comment'
      defined = 'http://www.w3.org/2000/01/rdf-schema#isDefinedBy'
      logicType = 'http://purl.net/dol/1.0/rdf#Logic'
      logic = 'http://ontohub.org/CommonLogic'
      @store = TripleStore.new [
        [logic, type, logicType],
        [logic, label, 'Common Logic'],
        [logic, comment, 'A language with all operators'],
        [logic, defined, 'http://ontohub.org/CommonLogic.rdf']
      ]
      @logicReader = LogicPopulation.new @store
    end

    should "make one-element list" do
      list = @logicReader.list;
      assert_equal 1, list.length
      logic = list[0]
      assert_equal 'http://ontohub.org/CommonLogic', logic.iri
      assert_equal 'Common Logic', logic.name
      assert_equal 'A language with all operators', logic.description
      assert_equal 'http://ontohub.org/CommonLogic.rdf', logic.defined_by
    end
  end

end

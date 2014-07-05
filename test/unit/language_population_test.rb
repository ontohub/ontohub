require 'test_helper'

# Tests a triple store
#
# Author: Daniel Couto Vale <danielvale@uni-bremen.de>
#
class TripleStoreTest < ActiveSupport::TestCase

  # The triple store
  @store

  context 'Empty Triple List:' do
    setup do
      @store = TripleStore.new []
      @languageReader = LanguagePopulation.new @store;
    end

    should "make empty list" do
      assert_equal [], @languageReader.list
    end
  end

  context 'File Load:' do
    setup do
      type = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
      label = 'http://www.w3.org/2000/01/rdf-schema#label'
      comment = 'http://www.w3.org/2000/01/rdf-schema#comment'
      defined = 'http://www.w3.org/2000/01/rdf-schema#isDefinedBy'
      languageType = 'http://purl.net/dol/1.0/rdf#OntologyLanguage'
      language = 'http://ontohub.org/CommonLanguage'
      @store = TripleStore.new [
        [language, type, languageType],
        [language, label, 'Common Language'],
        [language, comment, 'A language with all operators'],
        [language, defined, 'http://ontohub.org/CommonLanguage.rdf']
      ]
      @languageReader = LanguagePopulation.new @store
    end

    should "make one-element list" do
      list = @languageReader.list;
      assert_equal 1, list.length
      language = list[0]
      assert_equal 'http://ontohub.org/CommonLanguage', language.iri
      assert_equal 'Common Language', language.name
      assert_equal 'A language with all operators', language.description
      assert_equal 'http://ontohub.org/CommonLanguage.rdf', language.defined_by
    end
  end

end

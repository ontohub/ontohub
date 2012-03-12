require 'test_helper'

class HetsTest < ActiveSupport::TestCase
  context 'hets' do
    setup do
      assert_nothing_raised do
        `rm -f test/fixtures/ontologies/owl/*.xml`
        @path = Hets.parse 'test/fixtures/ontologies/owl/pizza.owl'
      end
    end

    should 'have created output file' do
      assert File.exists? @path
    end

    should 'have generated importable output' do
      assert_nothing_raised do
        ontology = Factory :ontology
        ontology.import_xml_from_file @path
      end
    end

    should 'raise exception if provided with wrong file-format' do
      assert_raise Hets::HetsError do
        Hets.parse 'test/fixtures/ontologies/valid.xml'
      end
    end
  end
end

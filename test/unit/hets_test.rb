require 'test_helper'

class HetsTest < ActiveSupport::TestCase
  %w(owl/pizza.owl owl/generations.owl clif/cat.clif).each do |path|
    context path do
      setup do
        assert_nothing_raised do
          p path
          @xml_path = Hets.parse "test/fixtures/ontologies/#{path}"
        end
      end

      should 'have created output file' do
        assert File.exists? @xml_path
      end

      should 'have generated importable output' do
        assert_nothing_raised do
          ontology = Factory :ontology
          ontology.import_xml_from_file @xml_path
          `rm -f #{@xml_path}`
        end
      end
    end
  end

  should 'raise exception if provided with wrong file-format' do
    assert_raise Hets::HetsError do
      Hets.parse 'test/fixtures/ontologies/xml/valid.xml'
    end
  end
end

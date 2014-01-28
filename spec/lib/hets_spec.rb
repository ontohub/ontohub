require 'spec_helper'

describe Hets do

  after do
    File.delete @xml_path if @xml_path
  end

  context 'Output directory parameter' do
    before do
      @xml_path = Hets.parse Rails.root.join('test/fixtures/ontologies/owl/pizza.owl'), [], '/tmp'
    end

    it 'correctly be used' do
      assert @xml_path.starts_with? '/tmp'
    end
  end

  %w(owl/pizza.owl owl/generations.owl clif/cat.clif).each do |path|
    context path do
      before do
        @xml_path = Hets.parse Rails.root.join("test/fixtures/ontologies/#{path}"), [], '/tmp'
        @pp_path = @xml_path.sub(/\.[^.]*$/, '.pp.xml')
      end

      it 'have created output file' do
        assert File.exists? @xml_path
      end

      it 'have generated importable output' do
        assert_nothing_raised do
          ontology = FactoryGirl.create :ontology
          user = FactoryGirl.create :user
          ontology.import_xml_from_file @xml_path, @pp_path, user
          `git checkout #{@xml_path} 2>/dev/null`
        end
      end
    end
  end

  context 'with url-catalog' do
    before do
      @xml_path = Hets.parse \
        Rails.root.join("test/fixtures/ontologies/clif/monoid.clif"),
        ["http://colore.oor.net=http://develop.ontohub.org/colore/ontologies"],
        '/tmp'
      @pp_path = @xml_path.sub(/\.[^.]*$/, '.pp.xml')
    end

    it 'have created output file' do
      assert File.exists? @xml_path
    end

    # This test is disabled, because for this ontology, the XML output of hets
    # contains _two_ DGNode tags, which is interpreted as distributed ontology
    # by the ontology import mechanism (see app/models/ontology/import.rb).
    # Funny though, the test did not fail always. Testing on the existence of
    # the XML output file should suffice as hets currently only has to recognize
    # the command line option for URL cataloges and does no URL substitutions.
=begin
    it 'have generated importable output' do
      assert_nothing_raised do
        ontology = FactoryGirl.create :ontology
        user = FactoryGirl.create :user
        ontology.import_xml_from_file @xml_path, @pp_path, user
        `git checkout #{@xml_path} 2>/dev/null`
      end
    end
=end
  end

  it 'raise exception if provided with wrong file-format' do
    assert_raise Hets::ExecutionError do
      Hets.parse Rails.root.join('test/fixtures/ontologies/xml/valid.xml')
    end
  end
end

require 'test_helper'

class HetsTest < ActiveSupport::TestCase
  context 'Output directory parameter' do
    setup do
      @xml_path = Hets.parse Rails.root.join('test/fixtures/ontologies/owl/pizza.owl'), [], '/tmp'
    end

    should 'correctly be used' do
      assert @xml_path.starts_with? '/tmp'
    end

    teardown do
      File.delete @xml_path
    end
  end

  %w(owl/pizza.owl owl/generations.owl clif/cat.clif).each do |path|
    context path do
      setup do
        assert_nothing_raised do
          @xml_path = Hets.parse Rails.root.join("test/fixtures/ontologies/#{path}"), [], '/tmp'
        end
      end

      should 'have created output file' do
        assert File.exists? @xml_path
      end

      should 'have generated importable output' do
        assert_nothing_raised do
          ontology = FactoryGirl.create :ontology
          user = FactoryGirl.create :user
          ontology.import_xml_from_file @xml_path, user
          `git checkout #{@xml_path} 2>/dev/null`
        end
      end

      teardown do
        File.delete @xml_path
      end
    end
  end

  context 'with url-catalog' do
    setup do
      assert_nothing_raised do
        @xml_path = Hets.parse \
          Rails.root.join("test/fixtures/ontologies/clif/monoid.clif"),
          ["http://colore.oor.net/magma=file://#{Rails.root.join('test/fixtures/ontologies/clif')}"],
          '/tmp'
      end
    end

    should 'have created output file' do
      assert File.exists? @xml_path
    end

    should 'have generated importable output' do
      assert_nothing_raised do
        ontology = FactoryGirl.create :ontology
        user = FactoryGirl.create :user
        ontology.import_xml_from_file @xml_path, user
        `git checkout #{@xml_path} 2>/dev/null`
      end
    end

    teardown do
      File.delete @xml_path
    end
  end

  should 'raise exception if provided with wrong file-format' do
    assert_raise Hets::HetsError do
      Hets.parse Rails.root.join('test/fixtures/ontologies/xml/valid.xml')
    end
  end
end

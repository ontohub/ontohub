require 'integration_test_helper'
class EntityDisplayTest < ActionController::IntegrationTest
  context 'When text' do
    context 'does not contain name' do
      setup do
        # HACK setting state of ontology to 'done' so the ajax polling won't
        # interfere this test
        @entity = FactoryGirl.create :entity_with_ontology_version
        @entity.ontology.state = 'done'
        @entity.ontology.save
        @repository = @entity.ontology.repository

        visit repository_ontology_entities_path(@repository, @entity.ontology)
        @ths = all('th')
      end

      context 'page' do
        should 'have 3 <th> tags' do
          assert_equal 3, @ths.size
        end
      end

      context 'first <th>' do
        should 'have text "Text"' do
          assert_equal 'Text', @ths[1].text
        end
      end

      context 'second <th>' do
        should 'have text "Name"' do
          assert_equal 'Name', @ths[2].text
        end
      end
    end

    context 'contains name' do
      setup do
        @entity = FactoryGirl.create :entity_with_ontology_version,
          name: 'Foo',
          text: 'Foo Bar'
        @entity.ontology.state = 'done'
        @entity.ontology.save
        @repository = @entity.ontology.repository

        visit repository_ontology_entities_path(@repository, @entity.ontology)
      end

      context 'page' do
        setup do
          @ths = all('th')
        end

        should 'have 0 <th> tag' do
          assert_equal 0, @ths.size
        end
      end

      context 'and no IRI' do
        context 'and name equals text, there' do
          setup do
            @entity = FactoryGirl.create :entity_with_ontology_version,
              name: 'Foo',
              text: 'Foo'
            @entity.ontology.state = 'done'
            @entity.ontology.save
            @repository = @entity.ontology.repository

            visit repository_ontology_entities_path(@repository, @entity.ontology)
          end

          should 'be no highlighting' do
            assert_raise Capybara::ElementNotFound do
              find('strong.entity_highlight')
            end
          end
        end

        context 'name' do
          should 'be highlighted' do
            assert_equal find('strong.entity_highlight').text, @entity.name
          end
        end
      end

      context 'and an IRI' do
        setup do
          @entity = FactoryGirl.create :entity_with_ontology_version,
            text: 'Class <http://example.com/foo_class>',
            name: '<http://example.com/foo_class>'
          @entity.ontology.state = 'done'
          @entity.ontology.save
          @repository = @entity.ontology.repository

          visit repository_ontology_entities_path(@repository, @entity.ontology)
        end
      end
    end
  end
end

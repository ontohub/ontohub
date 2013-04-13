require 'integration_test_helper'

class EntityDisplayTest < ActionController::IntegrationTest
  context 'When text' do
    context 'does not contain name' do
      setup do
        @entity = FactoryGirl.create :entity
        visit ontology_entities_path(@entity.ontology)
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
        @entity = FactoryGirl.build :entity
        @entity.text = 'Foo Bar'
        @entity.name = 'Foo'
        @entity.save!

        visit ontology_entities_path(@entity.ontology)
      end

      context 'page' do
        setup do
          @ths = all('th')
        end

        should 'have 2 <th> tag' do
          assert_equal 2, @ths.size
        end
      end

      context 'and no IRI' do
        context 'and name equals text, there' do
          setup do
            @entity = FactoryGirl.build :entity
            @entity.text = 'Foo'
            @entity.name = 'Foo'
            @entity.save!
            
            visit ontology_entities_path(@entity.ontology)
          end

          should 'be no highlighting' do
            assert_raise Capybara::ElementNotFound do
              find('span.entity_highlight')
            end
          end
        end

        context 'name' do
          should 'be highlighted' do
            assert_equal find('span.entity_highlight').text, @entity.name
          end
        end
      end

      context 'and an IRI' do
        setup do
          @entity = FactoryGirl.build :entity
          @entity.text = 'Class <http://example.com/foo_class>'
          @entity.name = '<http://example.com/foo_class>'
          @entity.save!

          visit ontology_entities_path(@entity.ontology)
        end

        context 'tooltip' do
          should 'exist for display_name' do
            assert_equal find('span.entity_tooltip').text, @entity.display_name
          end
          should 'be iri' do
            tooltip_title = find('span.entity_tooltip')[:'data-original-title']
            assert_equal tooltip_title, @entity.iri
          end
        end
      end
    end
  end
end

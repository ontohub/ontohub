require 'test_helper'

class EntityHelperTest < ActionView::TestCase
  context 'text_with_highlighted_fragment' do
    setup do
      @entity = FactoryGirl.create :entity_with_fragment
      @text = text_with_highlighted_fragment @entity
    end

    should 'escape < and > and then highlight (with unescaped html)' do
      assert_equal 'Class &lt;http://example.com/resource#<strong>Fragment</strong>&gt;', @text
    end
  end
end

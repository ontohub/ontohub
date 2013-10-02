require 'test_helper'

class SentenceHelperTest < ActionView::TestCase

  context 'Redundant names' do
    setup do
      @sentence = FactoryGirl.create(:sentence)
      @sentence.name = 'aaaa'
      @sentence.text = 'fasdfiasdf %(aaaa)%'
    end
    should 'should be removed from text' do
      assert_equal 'fasdfiasdf', format_for_view(@sentence)
    end
  end

# context 'Full entity iris'
#   setup do
#     @sentence = FactoryGirl.create(:sentence, :owl2)
#   end
#   should 'should be replaced by boldened display_name' do
#     assert_equal 2, format_for_view(@sentence).scan(/'strong'/)
#   end

end

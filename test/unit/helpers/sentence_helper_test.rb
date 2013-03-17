require 'test_helper'

class SentenceHelperTest < ActionView::TestCase

  context 'Sentence display' 
    setup do
      @sentence = FactoryGirl.create(:sentence)
      @sentence.name = 'aaaa'
      @sentence.text = 'fasdfiasdf %(aaaa)%'
    end
    should 'remove redundant name from text' do
      assert_equal 'fasdfiasdf', text_stripper(@sentence)
    end
  
end

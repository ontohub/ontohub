require 'spec_helper'

describe SentenceHelper do
  context 'Redundant names' do
    let(:sentence) do
      FactoryGirl.create :sentence,
        name: 'aaaa', text: 'fasdfiasdf %(aaaa)%'
    end

    it 'should be removed from text' do
      expect(format_for_view(sentence)).to eq('fasdfiasdf')
    end
  end
end

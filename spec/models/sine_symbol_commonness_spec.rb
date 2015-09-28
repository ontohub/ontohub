require 'spec_helper'

describe SineSymbolCommonness do
  context 'associations' do
    it { expect(subject).to belong_to(:symbol) }
  end
end

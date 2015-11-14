require 'spec_helper'

describe FrequentSymbol do
  context 'associations' do
    it { expect(subject).to belong_to(:frequent_symbol_set) }
    it { expect(subject).to belong_to(:symbol) }
  end
end

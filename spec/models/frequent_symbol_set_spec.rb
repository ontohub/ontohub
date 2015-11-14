require 'spec_helper'

describe FrequentSymbolSet do
  context 'associations' do
    it { expect(subject).to belong_to(:axiom_selection) }
    it { expect(subject).to have_many(:frequent_symbols) }
    it { expect(subject).to have_many(:symbols) }
    it { expect(subject).to have_many(:sine_symbol_commonnesses) }
  end
end

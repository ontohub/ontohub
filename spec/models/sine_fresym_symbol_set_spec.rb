require 'spec_helper'

describe SineFresymSymbolSet do
  context 'associations' do
    it { expect(subject).to belong_to(:sine_fresym_axiom_selection) }
    it { expect(subject).to have_many(:sine_fresym_symbols) }
    it { expect(subject).to have_many(:symbols) }
    it { expect(subject).to have_many(:sine_symbol_commonnesses) }
  end
end

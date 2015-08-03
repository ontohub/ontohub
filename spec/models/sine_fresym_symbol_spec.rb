require 'spec_helper'

describe SineFresymSymbol do
  context 'associations' do
    it { expect(subject).to belong_to(:sine_fresym_symbol_set) }
    it { expect(subject).to belong_to(:symbol) }
  end
end

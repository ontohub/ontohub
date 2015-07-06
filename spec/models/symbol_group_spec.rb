require 'spec_helper'

describe SymbolGroup do

  context 'the name expect(subject).to be displayed' do
    let(:symbol_group) {build :symbol_group}

    it 'should have the same value on name and to_s' do
      expect(symbol_group.name).to eq(symbol_group.to_s)
    end
  end
end

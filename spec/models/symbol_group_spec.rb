require 'spec_helper'

describe SymbolGroup do

  context 'the name should be displayed' do
    let(:symbol_group) {build :symbol_group}

    it 'should have the same value on name and to_s' do
      symbol_group.name.should equal(symbol_group.to_s)
    end
  end
end

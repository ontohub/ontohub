require 'spec_helper'

describe EntityGroup do

  context 'the name should be displayed' do
    let(:entity_group) {build :entity_group}

    it 'should have the same value on name and to_s' do
      entity_group.name.should equal(entity_group.to_s)
    end
  end
end

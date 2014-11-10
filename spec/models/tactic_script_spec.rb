require 'spec_helper'

describe TacticScript do
  context 'Associations' do
    it { should belong_to(:proof_status) }
  end

  it { should strip_attribute :script }

  context 'Validations' do
    ['foo', '/path/to/script.prf', 'A multiword script'].each do |val|
      it { should allow_value(val).for :script }
    end

    [nil, '',' '].each do |val|
      it { should_not allow_value(val).for :script }
    end
  end
end

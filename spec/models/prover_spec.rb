require 'spec_helper'

describe Prover do
  let(:prover) { create :prover }
  it 'to_s is the name' do
    expect(prover.to_s).to eq(prover.name)
  end
end

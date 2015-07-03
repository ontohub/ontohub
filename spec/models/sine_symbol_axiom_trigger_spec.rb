require 'spec_helper'

describe SineSymbolAxiomTrigger do
  context 'associations' do
    it { expect(subject).to belong_to :symbol }
    it { expect(subject).to belong_to :axiom }
  end
end

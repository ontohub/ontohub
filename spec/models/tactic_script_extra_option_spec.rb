require 'spec_helper'

describe TacticScriptExtraOption do
  context 'Associations' do
    it { should belong_to(:tactic_script) }
  end

  context 'validations' do
    let(:tseo) { create :tactic_script_extra_option }

    it 'is valid' do
      expect(tseo).to be_valid
    end

    context 'without option' do
      before { tseo.option = nil }

      it 'is invalid' do
        expect(tseo).to be_invalid
      end
    end
  end
end

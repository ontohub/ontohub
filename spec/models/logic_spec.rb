require 'spec_helper'

describe Logic do
  context 'Logic instance' do
    let(:user) { FactoryGirl.create :user }
    let(:logic) { FactoryGirl.create :logic, user: user }

    it 'have to_s' do
      expect(logic.to_s).to eq(logic.name)
    end

    it 'allow http scheme for IRI' do
      expect do
        logic.iri = 'http://example.com/logic'
        logic.save!
      end.not_to raise_error
    end

    it 'allow URN scheme for IRI' do
      expect do
        logic.iri = 'urn:logic:CommonLogic'
        logic.save!
      end.not_to raise_error
    end

    it 'not allow ftp scheme for IRI' do
      expect do
        logic.iri = 'ftp://example.com/logic'
        logic.save!
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end

require 'spec_helper'

describe Repository do

  let(:repository) { create :repository }

  context 'when trying to rename a repository' do
    it 'should fail to validate' do
      repository.name = "#{repository.name}addition"
      expect { repository.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

end

require 'spec_helper'

describe User do
  context 'when there are only two users, one admin and one not' do
    let!(:admin) { create :admin }
    let!(:user) { create :user }

    it 'should raise no error when deleting the user' do
      expect { user.destroy }.not_to raise_error
    end

    it 'should raise an error when trying to delete the admin' do
      expect { admin.destroy }.to raise_error(Permission::PowerVaccuumError)
    end
  end
end

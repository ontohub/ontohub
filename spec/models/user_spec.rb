require 'spec_helper'

describe User do
  context 'associations' do
    %i(comments ontology_versions team_users teams permissions keys).
      each do |association|
      it { should have_many(association) }
    end
  end

  it { should strip_attribute :name }
  it { should strip_attribute :email }
  it { should_not strip_attribute :password }

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

  context 'User instance' do
    let(:mails_sent) { ActionMailer::Base.deliveries.size }
    let(:user) { FactoryGirl.create :user }

    it 'not send email to *@example.com' do
      expect(ActionMailer::Base.deliveries.size).to eq(mails_sent)
    end

    it 'have email' do
      expect(user.email).not_to be_nil
    end

    it 'have name' do
      expect(user.name).not_to be_nil
    end

    it 'not have deleted_at' do
      expect(user.deleted_at).to be_nil
    end

    context 'after deletion' do
      before { user.delete }

      it 'have blank email' do
        expect(user.email).to be_nil
      end

      it 'have deleted_at' do
        expect(user.deleted_at).not_to be_nil
      end
    end

  end

  context 'Another user instance' do
    let!(:mails_sent) { ActionMailer::Base.deliveries.size }
    let!(:user) { FactoryGirl.create :user, email: 'user@noexample.com' }

    it 'send email' do
      expect(ActionMailer::Base.deliveries.size).to eq(mails_sent+1)
    end
  end

  context 'Admin instance' do
    let(:admins) { 2.times.map { FactoryGirl.create :admin } }

    it 'destroy one admin' do
      expect(admins.first.destroy).to be_truthy
    end

    it 'destroy not destroy all admins' do
      expect { admins.each(&:destroy) }.
        to raise_error(Permission::PowerVaccuumError)
    end
  end
end

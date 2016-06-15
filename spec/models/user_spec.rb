require 'spec_helper'

describe User do
  context 'associations' do
    %i(comments ontology_versions team_users teams permissions keys
       authored_commits committed_commits pushed_commits).
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
    let(:user) { create :user }

    it 'not send email to *@example.com' do
      expect(ActionMailer::Base.deliveries.size).to eq(mails_sent)
    end

    it 'have email' do
      expect(user.email).not_to be(nil)
    end

    it 'have name' do
      expect(user.name).not_to be(nil)
    end

    it 'not have deleted_at' do
      expect(user.deleted_at).to be(nil)
    end

    context 'after deletion' do
      before { user.delete }

      it 'have blank email' do
        expect(user.email).to be(nil)
      end

      it 'have deleted_at' do
        expect(user.deleted_at).not_to be(nil)
      end
    end

  end

  context 'Another user instance' do
    let!(:mails_sent) { ActionMailer::Base.deliveries.size }
    let!(:user) { create :user, email: 'user@noexample.com' }

    it 'send email' do
      expect(ActionMailer::Base.deliveries.size).to eq(mails_sent+1)
    end
  end

  context 'Admin instance' do
    let(:admins) { 2.times.map { create :admin } }

    it 'destroy one admin' do
      expect(admins.first.destroy).to be_truthy
    end

    it 'destroy not destroy all admins' do
      expect { admins.each(&:destroy) }.
        to raise_error(Permission::PowerVaccuumError)
    end
  end

  context 'considering commits' do
    let(:author) { create :user }
    let(:committer) { create :user }
    let(:pusher) { create :user }
    let!(:commit) do
      create :commit, author: author, committer: committer, pusher: pusher
    end

    context 'the author' do
      it 'has correct authored_commits' do
        expect(author.authored_commits).to match_array([commit])
      end

      it 'has correct committed_commits' do
        expect(author.committed_commits).to match_array([])
      end

      it 'has correct pushed_commits' do
        expect(author.pushed_commits).to match_array([])
      end
    end

    context 'the committer' do
      it 'has correct authored_commits' do
        expect(committer.authored_commits).to match_array([])
      end

      it 'has correct committed_commits' do
        expect(committer.committed_commits).to match_array([commit])
      end

      it 'has correct pushed_commits' do
        expect(committer.pushed_commits).to match_array([])
      end
    end

    context 'the pusher' do
      it 'has correct authored_commits' do
        expect(pusher.authored_commits).to match_array([])
      end

      it 'has correct committed_commits' do
        expect(pusher.committed_commits).to match_array([])
      end

      it 'has correct pushed_commits' do
        expect(pusher.pushed_commits).to match_array([commit])
      end
    end
  end
end

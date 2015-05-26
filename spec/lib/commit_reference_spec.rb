require 'spec_helper'

describe CommitReference do
  let(:repository) { create :repository_with_commits }
  let(:head_oid) { repository.git.send(:head).oid }
  let(:reference) { nil }
  let(:commit_reference) { CommitReference.new(repository, reference) }


  context 'when resolving a branch reference' do
    let(:reference) { 'master' }

    it 'shall find the correct oid' do
      expect(commit_reference.commit_oid).to eq(head_oid)
    end
  end

  context 'when resolving a date reference' do
    let(:reference) { Time.now.strftime("%Y-%m-%d") }

    it 'shall find the correct oid' do
      expect(commit_reference.commit_oid).to eq(head_oid)
    end
  end

  context 'when resolving a specific commit reference' do
    let(:commit_oid) { repository.git.commits.first.oid }
    let(:reference) { commit_oid }

    it 'shall find the correct oid' do
      expect(commit_reference.commit_oid).to eq(commit_oid)
    end
  end
end

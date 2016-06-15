require 'spec_helper'

describe Commit do
  context 'associations' do
    %i(ontology_versions ontologies).each do |association|
      it { should have_many(association) }
    end

    %i(repository author committer pusher).each do |association|
      it { should belong_to(association) }
    end
  end

  context 'saving a commit' do
    let(:repository) { create :repository }
    let(:pusher) { create :user }
    let(:file) { 'clif/Px.clif' }

    before do
      stub_hets_for(file)
    end

    context 'with author, committer and pusher being the same user' do
      let!(:commit_oid) do
        repository.save_file(ontology_file(file),
                             File.basename(file), 'add file', pusher).commit_oid
      end
      let(:commit) { repository.commits.where(commit_oid: commit_oid).first }
      subject { commit }

      %i(author committer pusher).each do |field|
        it "saves the #{field}" do
          expect(subject.send(field)).to eq(pusher)
        end

        it "saves the #{field}_name" do
          expect(subject.send("#{field}_name")).to eq(pusher.name)
        end
      end

      %i(author committer).each do |field|
        it "saves the #{field}_email" do
          expect(subject.send("#{field}_email")).to eq(pusher.email)
        end
      end
    end

    context 'with different author, committer, pusher' do
      let(:author) { create :user }
      let(:committer) { create :user }
      let(:author_data) do
        {name: author.name, email: author.email, time: Time.now}
      end
      let(:committer_data) do
        {name: committer.name, email: committer.email, time: Time.now}
      end

      before do
        allow_any_instance_of(GitRepository).
          to receive(:commit_author).and_return(author_data)
        allow_any_instance_of(GitRepository).
          to receive(:commit_committer).and_return(committer_data)
      end

      let(:commit_oid) do
        repository.save_file(ontology_file(file),
                             File.basename(file), 'add file', pusher).commit_oid
      end
      let(:commit) { repository.commits.where(commit_oid: commit_oid).first }
      subject { commit }

      it "saves the author's association" do
        expect(subject.author).to eq(author)
      end

      it "saves the author's name" do
        expect(subject.author_name).to eq(author.name)
      end

      it "saves the author's email" do
        expect(subject.author_email).to eq(author.email)
      end

      it "saves the committer's association" do
        expect(subject.committer).to eq(committer)
      end

      it "saves the committer's name" do
        expect(subject.committer_name).to eq(committer.name)
      end

      it "saves the committer's email" do
        expect(subject.committer_email).to eq(committer.email)
      end

      it "saves the pusher's association" do
        expect(subject.pusher).to eq(pusher)
      end

      it "saves the pusher's name" do
        expect(subject.pusher_name).to eq(pusher.name)
      end
    end
  end
end

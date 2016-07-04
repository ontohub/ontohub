require 'spec_helper'

describe 'Repository saving a file' do
  let(:user)        { create :user }
  let(:repository)  { create :repository, user: user }
  let(:target_path) { 'save_file.clif' }
  let(:message)     { 'test message' }
  let(:content)     { "(Cat x)\n" }
  let(:file_path)   do
    tmpfile = Tempfile.new('repository_test')
    tmpfile.write(content)
    tmpfile.close

    tmpfile
  end

  context 'saving a file' do
    it 'should not have an ontology yet' do
      expect(repository.ontologies.count).to eq(0)
    end

    context "that doesn't exist" do
      before do
        @version = repository.save_file(file_path, target_path, message, user)
      end

      it 'create the file in the git repository' do
        expect(repository.git.path_exists?(target_path)).to be(true)
      end

      it 'create the file with correct contents in the git repository' do
        expect(repository.git.get_file(target_path).content).to eq(content)
      end

      it 'create a new ontology' do
        expect(repository.ontologies.count).to eq(1)
      end

      it 'create a new ontology with a default name' do
        expect(repository.ontologies.first.name).to eq('Save_file')
      end

      it 'create a new ontology with only one version' do
        expect(repository.ontologies.first.versions.count).to eq(1)
      end

      it 'create a new ontology with its version pointing to the commit' do
        o = repository.ontologies.first
        expect(o.versions.first[:commit_oid]).to eq(@version.commit_oid)
      end

      it 'create a new ontology with only one version belonging to the right user' do
        v = repository.ontologies.first.versions.first
        expect(v.pusher).to eq(user)
      end

      it 'should have the ontology marked as having a file' do
        expect(repository.ontologies.first.has_file).to be_truthy
      end
    end

    context 'updating' do
      let(:file_path2)   do
        tmpfile = Tempfile.new('repository_test')
        tmpfile.write(content*2)
        tmpfile.close

        tmpfile
      end

      before do
        repository.save_file(file_path, target_path, message, user)
        repository.save_file(file_path2, target_path, message, user)
      end

      it 'create a new ontology version' do
        expect(repository.ontologies.
               where(basepath: File.basepath(target_path)).
               first!.versions.count).to eq(2)
      end
    end
  end

  context 'delete the file' do
    before do
      @version_save = repository.save_file(file_path, target_path, message, user)
      @version_del = repository.delete_file(target_path, user)
    end

    it 'delete the file in the git repository' do
      expect(repository.git.path_exists?(target_path)).to be_falsy
    end

    it 'should have the ontology marked as having no file' do
      expect(repository.ontologies.first.has_file).to be_falsy
    end

    it 'should have the ontology marked as having a file at the old version' do
      expect(repository.ontologies.first.has_file(@version_save.commit_oid)).
        to be_truthy
    end

    context 'that already exists' do
      it 'create a job' do
        expect { repository.save_file(file_path, target_path, message, user) }.
          to change { OntologyParsingWorker.jobs.count }.by(1)
      end
    end
  end
end

require 'spec_helper'

describe Repository do
  setup_hets

  let(:repository) { create :repository_with_remote, remote_type: 'mirror' }

  context 'when ontohub clones a remote repository' do

    before do
      stub_hets_for('clif/cat1.clif', with: 'cat', with_version: 1)
      stub_hets_for('clif/cat2.clif', with: 'cat', with_version: 2)
      stub_hets_for('clif/Px.clif', with: 'Px')
    end

    it 'should create a bulk job on a queue' do
      expect { repository.fetch('clone') }.
        to change(OntologyBatchParseWorker.jobs, :size)
    end

    it 'should run the ontology import on the cloned repository', process_jobs_synchronously: true do
      expect { repository.fetch('clone') }.
        not_to raise_error
    end
  end
end

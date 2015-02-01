require 'spec_helper'

describe Repository do
  setup_hets

  let(:repository) { create :repository_with_remote, remote_type: 'mirror' }

  context 'when ontohub clones a remote repository' do

    before do
      stub_hets_for(hets_out_file('cat1'), with: 'cat', with_version: 1)
      stub_hets_for(hets_out_file('cat2'), with: 'cat', with_version: 2)
      stub_hets_for(hets_out_file('Px'), with: 'Px')
    end

    it 'should create a bulk job on a queue' do
      expect { repository.remote_send('clone') }.
        to change(OntologyBatchParseWorker.jobs, :size)
    end

    it 'should run the ontology import on the cloned repository', process_jobs_synchronously: true do
      expect { repository.remote_send('clone') }.
        not_to raise_error
    end
  end
end

require 'spec_helper'

describe Repository do
  setup_hets

  let(:repository) { create :repository_with_remote }

  context 'when ontohub clones a remote repository' do
    it 'should create a bulk job on a queue' do
      expect { repository.remote_send('clone') }.
        to change(OntologyBatchParseWorker.jobs, :size)
    end

    it 'should run the ontology import on the cloned repository', process_jobs_synchronously: true do
      skip 'Fails cause it needs time-specific stubbing!'
      expect { repository.remote_send('clone') }.
        not_to raise_error
    end
  end
end

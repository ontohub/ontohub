require 'spec_helper'

describe Repository do

  let(:repository) { create :repository }

  context 'when trying to rename a repository' do
    it 'should fail to validate' do
      repository.name = "#{repository.name}addition"
      expect { repository.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'when deleting a repository' do
    let (:ontology) { create :ontology, repository: repository }

    context 'with ontologies that import internally' do
      it 'should not raise an error' do
        importing = create :ontology, repository: repository
        create :link, target: importing, source: ontology, kind: 'import'
        expect { repository.destroy }.not_to raise_error
      end
    end

    context 'with ontologies that are imported externally' do
      it 'should raise an error' do
        repository2 = create :repository
        importing   = create :ontology, repository: repository2
        create :link, target: importing, source: ontology, kind: 'import'
        expect { repository.destroy }.to raise_error(Ontology::DeleteError)
      end
    end

  end
end

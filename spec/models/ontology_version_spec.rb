require 'spec_helper'

describe OntologyVersion do
  it { should belong_to :ontology }
  it { should belong_to :commit }
  it { should have_one :author }
  it { should have_one :committer }
  it { should have_one :pusher }

  it { should have_db_index([:ontology_id, :number]) }
  it { should have_db_index(:commit_oid) }
  it { should have_db_index(:checksum) }

  let(:user) { create :user }

  context 'OntologyVersion' do
    let(:ontology_version) { create :ontology_version }

    it 'should have a url' do
      version_url_regex = %r{
        http://example\.com/repositories/
        #{ontology_version.repository.path}/
        ontologies/\d+/versions/\d+$
      }x
      expect(ontology_version.url).to match(version_url_regex)
    end
  end

  context 'scopes' do
    context 'accessible by' do
      let(:repository) { create :repository, access: 'private_rw' }
      let!(:ontology) { create :ontology, repository: repository }
      let(:editor) { create :user }
      let!(:permission) { create(:permission, subject: editor, role: 'editor',
        item: repository) }

      it 'editor' do
        expect(OntologyVersion.accessible_by(editor).all.map(&:id)).to include(ontology.current_version.id)
      end

      it 'user' do
        expect(OntologyVersion.accessible_by(user).all.map(&:id)).not_to include(ontology.current_version.id)
      end
    end
  end
end

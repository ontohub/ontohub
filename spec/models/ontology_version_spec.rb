require 'spec_helper'

describe OntologyVersion do
  it { should belong_to :user }
  it { should belong_to :ontology }

  it { should have_db_index([:ontology_id, :number]) }
  it { should have_db_index(:user_id) }
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
end

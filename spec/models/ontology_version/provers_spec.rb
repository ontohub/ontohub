require 'spec_helper'

describe 'OntologyVersion - Provers' do
  setup_hets
  let(:user) { create :user }
  let(:repository) { create :repository }

  before do
    stub_hets_for('prove/Simple_Implications.casl')
    @version =
      version_for_file(repository,
                       ontology_file('prove/Simple_Implications', 'casl'))
    @version.parse
  end

  let(:ontology) { @version.ontology }

  it 'have fetched available provers' do
    expect(@version.provers.count).to be > 0
  end

  it "all child ontologies' versions have fetched available provers" do
    ontology.children.each do |child|
      expect(child.current_version.provers.count).to be > 0
    end
  end
end

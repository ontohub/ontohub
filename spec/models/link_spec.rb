require 'spec_helper'

describe Link do

  let(:user) { create :user }
  let(:repository) { create :repository }
  let(:external_repository) { ExternalRepository.repository }

  context 'when importing an ontology' do
    context 'which belongs to a distributed ontology' do

      let(:dist_ontology) { create :distributed_ontology }
      let(:target_ontology) { dist_ontology.children.find_by_name('Features') }

      context 'and imports another ontology' do
        let(:source_ontology) { external_repository.ontologies.find_by_name('path:features.owl') }

        context 'which is not part of the distributed ontology' do
          let(:link) { dist_ontology.links.first }

          before do
            parse_this(user, dist_ontology, fixture_file('reference'))
          end

          it 'should have the link-source set correctly' do
            expect(link.source).to eq(source_ontology)
          end
          it 'should have the link-target set correctly' do
            expect(link.target).to eq(target_ontology)
          end

          it 'has a link-version set' do
            expect(link.link_version).to_not be_nil
          end

          it 'has a link-version that points to the current link-version' do
            expect(link.link_version).to eq(link.versions.current)
          end

        end
      end
    end
  end

end

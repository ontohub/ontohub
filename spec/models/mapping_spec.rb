require 'spec_helper'

describe Mapping do
  context 'associations' do
    %i(source target).each do |association|
      it { should belong_to(association) }
    end
  end

  let(:user) { create :user }
  let(:repository) { create :repository }
  let(:external_repository) { ExternalRepository.repository }

  context 'when importing an ontology' do
    context 'which belongs to a distributed ontology' do

      let(:dist_ontology) { create :distributed_ontology }
      let(:target_ontology) { dist_ontology.children.find_by_name('Features') }

      context 'and imports another ontology' do
        let(:source_ontology) do
          o = external_repository.ontologies.find_by_name('path:features.owl')
          # This is a workaround for a hets error.
          # See https://github.com/spechub/Hets/issues/1433 for details.
          o || external_repository.ontologies.find_by_name('path:')
        end

        context 'which is not part of the distributed ontology' do
          let(:mapping) { dist_ontology.mappings.first }

          before do
            parse_this(user, dist_ontology, hets_out_file('reference'))
          end

          it 'should have the mapping-source set correctly' do
            expect(mapping.source).to eq(source_ontology)
          end
          it 'should have the mapping-target set correctly' do
            expect(mapping.target).to eq(target_ontology)
          end

          it 'has a mapping-version set' do
            expect(mapping.mapping_version).to_not be_nil
          end

          it 'has a mapping-version that points to the current mapping-version' do
            expect(mapping.mapping_version).to eq(mapping.versions.current)
          end

        end
      end
    end
  end

end

require 'spec_helper'

def debug_prints
  puts "dist_ontology"
  puts dist_ontology.inspect
  puts ""
  puts "target_ontology"
  puts target_ontology.inspect
  puts ""
  puts "source_ontology"
  puts source_ontology.inspect
  puts ""
  puts "mapping"
  puts mapping.inspect
  puts ""
  puts "source"
  puts mapping.source.inspect
  puts ""
  puts "target"
  puts mapping.target.inspect
rescue NoMethodError
end

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
        let(:source_ontology) { external_repository.ontologies.find_by_name('path:features.owl') }

        context 'which is not part of the distributed ontology' do
          let(:mapping) { dist_ontology.mappings.first }

          before do
            parse_ontology(user, dist_ontology, 'dol/reference.dol')
          end

          it 'should have the mapping-source set correctly' do
            debug_prints
            expect(mapping.source).to eq(source_ontology)
          end

          it 'should have the mapping-target set correctly' do
            debug_prints
            expect(mapping.target).to eq(target_ontology)
          end

          it 'has a mapping-version set' do
            debug_prints
            expect(mapping.mapping_version).to_not be(nil)
          end

          it 'has a mapping-version that points to the current mapping-version' do
            debug_prints
            expect(mapping.mapping_version).to eq(mapping.versions.current)
          end

        end
      end
    end
  end

end

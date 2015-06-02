require 'spec_helper'

describe 'OntologyVersion - Proving' do
  let(:theorem) { create :theorem }
  let(:ontology) { theorem.ontology }
  let(:repository) { ontology.repository }
  let(:ontology_version) { ontology.current_version }

  context 'prove_options' do
    let(:prove_options) { ontology_version.prove_options }
    it 'have the ontology name as node parameter' do
      expect(prove_options.options[:node]).to eq(ontology.name)
    end

    it 'have no theorems parameter' do
      expect(prove_options.options[:theorems]).to be(nil)
    end

    context 'on a private repository' do
      before do
        repository.access = 'private_rw'
        repository.save!
      end

      it 'have an existing access-token parameter' do
        expect(prove_options.options[:'access-token']).to be_present
      end
      it 'have the access token as access-token parameter' do
        expect(prove_options.options[:'access-token']).
          to eq(repository.access_tokens.first.to_s)
      end
    end

    context 'with url-maps' do
      let!(:url_maps) { [create(:url_map, repository: repository)] }
      it 'have the url-maps as url-catalog parameter' do
        expect(prove_options.options[:'url-catalog']).to eq(url_maps.join(','))
      end
    end

    context 'without url-maps' do
      it 'have no url-catalog parameter' do
        expect(prove_options.options[:'url-catalog']).to be(nil)
      end
    end
  end
end

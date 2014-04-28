require 'spec_helper'

describe TranslatedSentence do

  context 'when parsing the CarsAreAudis ontology with symbol mappings' do
    let(:repository) { create :repository }
    let(:version) { add_fixture_file(repository, 'dol/double_import_blendoid.dol') }
    let(:ontology) { version.ontology }

    context 'translated sentences should be created correctly' do
      before do
        version.async_parse
      end

      it 'should contain a translated sentence for AudiA4 is Audi' do
        expect(TranslatedSentence.where(translated_text: 'Class: AudiA4 SubClassOf: Car')).not_to be_nil
      end
    end
  end

end

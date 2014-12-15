class TranslatedSentence < ActiveRecord::Base
  belongs_to :ontology
  belongs_to :audience, class_name: Ontology.to_s
  belongs_to :sentence
  belongs_to :symbol_mapping

  attr_accessible :audience, :ontology, :sentence, :symbol_mapping
  attr_accessible :translated_text

  delegate :name, to: :sentence

  def text
    translated_text
  end

  def display_text?
    false
  end

  # returns a translated sentence if
  # an applicable one could be found
  def self.choose_applicable(sentence, mapping)
    source = mapping.mapping.source
    where(audience_id: source, sentence_id: sentence).first || sentence
  end
end

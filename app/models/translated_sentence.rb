class TranslatedSentence < ActiveRecord::Base
  belongs_to :ontology
  belongs_to :audience, class_name: Ontology.to_s
  belongs_to :sentence
  belongs_to :entity_mapping

  attr_accessible :audience, :ontology, :sentence, :entity_mapping
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
    source = mapping.link.source
    where(audience_id: source, sentence_id: sentence).first || sentence
  end
end

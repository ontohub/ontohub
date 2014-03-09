class TranslatedSentence < ActiveRecord::Base
  belongs_to :ontology
  belongs_to :audience, class_name: Ontology.to_s
  belongs_to :sentence

  attr_accessible :audience, :ontology, :sentence
  attr_accessible :translated_text
end

class Sentence < ActiveRecord::Base
  include Metadatable
  include Readability

  belongs_to :ontology
  has_and_belongs_to_many :symbols, class_name: 'OntologyMember::Symbol'
  has_many :translated_sentences, dependent: :destroy
  default_scope where(imported: false, type: nil)

  attr_accessible :locid

  def self.find_with_locid(locid, _iri = nil)
    where(locid: locid).first
  end

  def hierarchical_class_names
    match = self.text.match(%r{
      \s*
      Class:
      \s*
      (?:
       <(?<first_class>.+)>|
       (?<first_class>.+)
      )
      \s*
      SubClassOf:
      \s*
      (?:
       <(?<second_class>.+)>|
       (?<second_class>.+)
      )
      \s*}x)
    if match
      [match[:first_class].strip, match[:second_class].strip]
    else
      []
    end
  end

  def to_s
    name
  end
end

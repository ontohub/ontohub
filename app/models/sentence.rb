class Sentence < LocIdBaseModel
  include Metadatable
  include Readability

  belongs_to :ontology
  has_and_belongs_to_many :symbols, class_name: 'OntologyMember::Symbol'
  has_many :translated_sentences, dependent: :destroy
  has_one :repository, through: :ontology

  scope :original, where(imported: false)

  alias_attribute :to_s, :name

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

  def generate_locid_string
    sep = '//'
    "#{ontology.locid}#{sep}#{name}"
  end
end

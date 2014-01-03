class Sentence < ActiveRecord::Base
  include Metadatable
  include Readability

  belongs_to :ontology
  has_and_belongs_to_many :entities

  def extract_class_names
    c1,c2 = self.text.split('SubClassOf:').map do |c|
      c.scan(URI::regexp(Settings.allowed_iri_schemes))
    end
    [ c1[0][-1], c2[0][-1] ]
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
      [match[:first_class], match[:second_class]]
    else
      []
    end
  end

end

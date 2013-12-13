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

end

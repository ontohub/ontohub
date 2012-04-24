class Language < ActiveRecord::Base
  has_many :supports
  has_many :ontologies
  has_many :serializations

  validates :name, length: { minimum: 1 }
  validates :iri, length: { minimum: 1 }
end

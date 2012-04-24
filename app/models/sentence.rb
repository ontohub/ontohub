class Sentence < ActiveRecord::Base
  include Metadatable

  belongs_to :ontology
  has_and_belongs_to_many :entities
end

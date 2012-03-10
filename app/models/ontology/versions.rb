module Ontology::Versions
  extend ActiveSupport::Concern

  included do
    has_many :versions, :dependent => :destroy, :class_name => 'OntologyVersion'

    attr_accessible :versions_attributes
    accepts_nested_attributes_for :versions
  end
end

module Ontology::Versions
  extend ActiveSupport::Concern

  included do
    belongs_to :ontology_version

    has_many :versions,
      :dependent  => :destroy,
      :order      => :number,
      :class_name => 'OntologyVersion' do
        def current
          reorder('number DESC').first
        end
      end

    attr_accessible :versions_attributes
    accepts_nested_attributes_for :versions
  end
  
  # Updates the ontology and returns the new version
  def save_file(file, message, user)
    repository.save_file(file, path, message, user)
  end

end

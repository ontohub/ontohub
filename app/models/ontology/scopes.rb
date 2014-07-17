module Ontology::Scopes
  extend ActiveSupport::Concern

  included do
    scope :without_parent, where('ontologies.parent_id' => nil)

    scope :basepath, ->(path) do
      joins(:ontology_version).where('ontology_versions.basepath' => path)
    end

    equal_scope *%w(
      repository_id
    )
  end

end

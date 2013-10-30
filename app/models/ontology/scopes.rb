module Ontology::Scopes
  extend ActiveSupport::Concern

  included do
    scope :without_parent, where(parent_id: nil)

    equal_scope *%w(
      repository_id
      basepath
    )
  end

end

module Ontology::Projects
  extend ActiveSupport::Concern

  included do
    belongs_to :projects
  end

end

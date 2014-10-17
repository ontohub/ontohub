module Ontology::Tasks
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :tasks
  end

end

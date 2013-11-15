module Ontology::Tasks
  extend ActiveSupport::Concern

  included do
    has_many :tasks
  end

end

module Ontology::States
  extend ActiveSupport::Concern

  STATES = State::STATES

  included do
    STATES.each do |state|
      eval "def #{state}?; state == '#{state}'; end"
    end
  end

  module ClassMethods
    # Enqueues new parse jobs for all failed ontologies
    def retry_failed
      state(:failed).without_parent.find_each do |ontology|
        OntologySaver.new(ontology.repository).
          async_parse_version(ontology.current_version)
      end
    end

    def count_by_state
      select("state, count(*) AS count").group(:state)
    end
  end

  def changeable?
    done? or failed?
  end
end

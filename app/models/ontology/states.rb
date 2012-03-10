module Ontology::States
  extend ActiveSupport::Concern

  STATES = %w(pending downloading processing done failed)

  included do
    validates_inclusion_of :state, :in => STATES

    STATES.each do |state|
      eval "def #{state}?; state == '#{state}'; end"
    end
  end

  def changeable?
    done? or failed?
  end
end

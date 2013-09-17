module Aggregatable
  extend ActiveSupport::Concern

  included do
  end

  def aggregate
    method_name = :"aggregate_#{self.class.to_s.downcase}"
    self.send(method_name)
  end

  private
  def aggregate_distributedontology
    aggregate_ontology
  end

  def aggregate_singleontology
    aggregate_ontology
  end

  def aggregate_ontology
    counts = entities.groups_by_kind.map { |entity| {name: entity.kind, count: entity.count} }
    {
      counts: counts
    }
  end

  def aggregate_logic
  end

end

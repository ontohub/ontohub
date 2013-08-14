module Ontology::Distributed
  extend ActiveSupport::Concern

  included do
    acts_as_tree

    def self.homogeneous
      select_with_character_selector('=')
    end

    def self.heterogeneous
      select_with_character_selector('>')
    end

    def self.heterogeneous_children
      ontologies = where("ontologies.type = 'DistributedOntology'").
        select { |ontology| ontology.heterogeneous?}
      where(parent_id: ontologies)
    end

    private
    def self.select_with_character_selector(selector="=")
      stmt = <<-STMT
(
SELECT distributed.id FROM
  (SELECT distributed_count.id, COUNT(distributed_count.id) AS occurrences FROM
    (SELECT (ontologies.parent_id) as id FROM ontologies
    GROUP BY ontologies.logic_id, ontologies.parent_id)
  AS distributed_count
GROUP BY distributed_count.id) AS distributed
WHERE distributed.occurrences #{selector} 1
)
      STMT
      where(type: DistributedOntology).where("ontologies.id IN #{stmt}")
    end

  end

  def distributed?
    is_a? DistributedOntology
  end

  def homogeneous?
    return true unless distributed?
    return true unless self.children.any?
    base_logic = self.children.first.logic
    self.children.count == self.children.where(logic_id: base_logic).count
  end

  def heterogeneous?
    return false unless distributed?
    not homogeneous?
  end

end

module Ontology::Distributed
  extend ActiveSupport::Concern

  included do
    def self.homogeneous
      select_with_character_selector(HOMOGENEOUS_SELECTOR)
    end

    def self.heterogeneous
      select_with_character_selector(HETEROGENEOUS_SELECTOR)
    end

    def self.heterogeneous_children
      where(parent_id: self.heterogeneous)
    end

    # Fetches homogeneous Ontologies which are distributed
    # and have children in the logic
    def self.distributed_in(logic)
      distributed_with(logic, HOMOGENEOUS_SELECTOR)
    end

    # Fetches heterogeneous Ontologies which are distributed
    # and have children in the logic
    def self.also_distributed_in(logic)
      distributed_with(logic, HETEROGENEOUS_SELECTOR)
    end

    private

    HOMOGENEOUS_SELECTOR = '='
    HETEROGENEOUS_SELECTOR = '>'

    def self.distributed_with(logic, selector='=')
      query = <<-STMT
WITH parents AS (
  SELECT (ontologies.parent_id) AS id FROM ontologies WHERE ontologies.logic_id = #{logic.id}
)
SELECT * FROM ontologies JOIN parents ON ontologies.parent_id = parents.id
      STMT
      select_with_character_selector(selector, query)
    end


    def self.select_with_character_selector(selector="=", ontologies_query=nil)
      query = ontologies_query ? "(#{ontologies_query}) AS ontologies" : "ontologies"
      stmt = <<-STMT
(
SELECT distributed.id FROM
  (SELECT distributed_count.id, COUNT(distributed_count.id) AS occurrences FROM
    (SELECT (ontologies.parent_id) as id FROM #{query}
    GROUP BY ontologies.logic_id, ontologies.parent_id)
  AS distributed_count
GROUP BY distributed_count.id) AS distributed
WHERE distributed.occurrences #{selector} 1
)
      STMT
      where(type: DistributedOntology).where("ontologies.id IN #{stmt}")
    end

  end

  public
  def distributed?
    is_a? DistributedOntology
  end

  def in_distributed?
    !! self.parent
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

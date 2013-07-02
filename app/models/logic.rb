#
# A named logic in the field of Logics.
#
# Examples:
# * Classical Logic
# * Common Logic
# * Description Logic
# * First-Order Logic
# * Modal Logic
#
class Logic < ActiveRecord::Base
  include Resourcable
  include Permissionable
  include Common::Scopes
  
  STAND_STATUS = %w( AcademicLiterature ISOStandard Unofficial W3CRecommendation W3CTeamSubmission W3CWorkingGroupNote )
  DEFINED_BY = %w( registry )
  
  has_many :ontologies
  has_many :supports
  has_many :logic_mappings, :foreign_key => :source_id

  # The creator of this logic in the system
  # The logic creator
  # * is not necessarily an owner nor an editor
  # * may be a current or former user of the system
  # * may be the original logician or anyone else
  belongs_to :user

  attr_accessible :name, :iri, :description, :standardization_status, :defined_by, :user

  validates_presence_of :name
  validates_uniqueness_of :name, if: :name_changed?

  validates_presence_of :iri
  validates_uniqueness_of :iri, if: :iri_changed?
  #validates_format_of :iri, with: URI::regexp(ALLOWED_URI_SCHEMAS)

  after_create :add_permission
  
  scope :autocomplete_search, ->(query) {
    where("name #{connection.ilike_operator} ?", "%" << query << "%")
  }

  def to_s
    name
  end
  
  def add_language(language)
    sup = self.supports.new
    sup.language = language
    sup.save!
  end
  
  def mappings_from
    LogicMapping.find_all_by_source_id self.id
  end
  
  def mappings_to
    LogicMapping.find_all_by_target_id self.id
  end
  
  def generate_graph(depth = 3)
    children = Array.new
    self.mappings_from.each do |mapping|
      children << mapping.target.generate_graph(depth - 1)
    end unless depth < 1
    
    self.mappings_to.each do |mapping|
      children << mapping.source.generate_graph(depth - 1)
    end unless depth < 1
    
    return {
        id: self.id,
        name:self.name, 
        children:children.uniq, 
        data:{band:"",relation:"root"}
      }
  end
  
private
  def add_permission
    permissions.create! :subject => self.user, :role => 'owner' if self.user
  end

  def determine_graph_nodes(depth = 3)
    sql = ->(stmt) { ActiveRecord::Base.connection.execute(stmt) }

    init_stmt = <<-SQL
    SELECT "ids"."id" INTO graph_ids FROM
      (SELECT ("logic_mappings"."source_id") AS id FROM "logic_mappings"
    WHERE ("logic_mappings"."source_id" = #{self.id} OR
      "logic_mappings"."target_id" = #{self.id})
    UNION
    SELECT ("logic_mappings"."target_id") AS id FROM "logic_mappings"
    WHERE ("logic_mappings"."source_id" = #{self.id} OR
      "logic_mappings"."target_id" = #{self.id})) AS ids;
    SQL

    loop_stmt = <<-SQL
    INSERT INTO graph_ids
    (SELECT ("logic_mappings"."source_id") AS id FROM "logic_mappings"
    INNER JOIN graph_ids
    ON ("logic_mappings"."source_id" = "graph_ids"."id" OR
      "logic_mappings"."target_id" = "graph_ids"."id")
    UNION
    SELECT ("logic_mappings"."target_id") AS id FROM "logic_mappings"
    INNER JOIN graph_ids
    ON ("logic_mappings"."source_id" = "graph_ids"."id" OR
      "logic_mappings"."target_id" = "graph_ids"."id"));
    SQL

    gather_stmt = ""

    (depth-1).times { gather_stmt << "#{loop_stmt}\n" }

    fetch_stmt = '(SELECT "graph_ids"."id" from "graph_ids")'

    drop_stmt = <<-SQL
    DROP TABLE IF EXISTS "graph_ids";
    SQL

    stmt = <<-SQL
    #{init_stmt}
    #{gather_stmt}
    SQL

    sql.call(drop_stmt)
    sql.call(init_stmt)
    sql.call(gather_stmt)
    nodes = Logic.where("\"logics\".\"id\" IN #{fetch_stmt}")

    nodes
  end
end

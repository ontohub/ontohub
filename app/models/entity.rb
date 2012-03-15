class Entity < ActiveRecord::Base
  
  include Metadatable
  include Entity::Searching

  belongs_to :ontology
  has_and_belongs_to_many :axioms
  
  scope :kind, ->(kind) { where :kind => kind }
  
  def self.grouped_by_kind
    select('kind, count(*) AS count').group(:kind).order('count DESC, kind').all
  end
  
end

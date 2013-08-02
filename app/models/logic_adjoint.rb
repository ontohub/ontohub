class LogicAdjoint < ActiveRecord::Base
  include Resourcable
  include Permissionable

  belongs_to :translation, class_name: 'LogicMapping'
  belongs_to :projection, class_name: 'LogicMapping'
  belongs_to :user

  validates_presence_of :translation, :projection, :iri

  attr_accessible :iri, :translation, :projection, :translation_id, :projection_id

  def to_s
    "#{iri}: #{translation} ADJOINTS  #{projection}"
  end

end

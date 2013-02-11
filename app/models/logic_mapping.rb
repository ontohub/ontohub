class LogicMapping < ActiveRecord::Base
  include Resourcable
  include Permissionable
  
  FAITHFULNESSES = %w( none faithful model_expansive model_bijective embedding sublogic )
  THEOROIDALNESSES = %w( plain simple_theoroidal theoroidal generalised )
  
  belongs_to :source, class_name: 'Logic'
  belongs_to :target, class_name: 'Logic'
  belongs_to :user
  attr_accessible :source_id, :target_id, :source, :target, :iri, :standardization_status, :defined_by, :default, :projection, :faithfulness, :theoroidalness
  
  after_create :add_permission
  
  def to_s
    "#{source} => #{target}"
  end
  
private

  def add_permission
    permissions.create! :subject => self.user, :role => 'owner' if self.user
  end
  
end

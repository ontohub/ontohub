class OopsResponse < ActiveRecord::Base
  belongs_to :request, class_name: 'OopsRequest'
  has_and_belongs_to_many :entities

  scope :global, joins("LEFT JOIN entities_oops_responses ON oops_responses.id = entities_oops_responses.oops_response_id").where('entities_oops_responses.entity_id' => nil)

  attr_accessor :affects

  attr_accessible :code, :description, :name, :element_type, :affects

  # create affects if present
  after_create :create_affects, if: :affects

  def create_affects
    request = OopsRequest.find(oops_request_id) # otherwise request is nil :-(
    self.entities = request.ontology_version.ontology.entities.where(iri: affects).all
  end

end

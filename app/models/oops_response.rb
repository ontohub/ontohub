class OopsResponse < ActiveRecord::Base
  belongs_to :request, class_name: 'OopsRequest'
  has_and_belongs_to_many :symbols

  scope :global, joins("LEFT JOIN symbols_oops_responses ON oops_responses.id = symbols_oops_responses.oops_response_id").where('symbols_oops_responses.symbol_id' => nil)

  attr_accessor :affects

  attr_accessible :code, :description, :name, :element_type, :affects

  # create affects if present
  after_create :create_affects, if: :affects

  def create_affects
    request = OopsRequest.find(oops_request_id) # otherwise request is nil :-(
    self.symbols = request.ontology_version.ontology.symbols.where(iri: affects).all
  end

end

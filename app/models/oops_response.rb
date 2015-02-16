class OopsResponse < ActiveRecord::Base
  belongs_to :request, class_name: 'OopsRequest'
  has_and_belongs_to_many :symbols, class_name: 'OntologyMember::Symbol'

  scope :global, ->() do
    table = 'oops_responses_symbols'
    joins("LEFT JOIN #{table} ON #{table}.id = #{table}.oops_response_id").
      where("#{table}.symbol_id" => nil)
  end

  attr_accessor :affects

  attr_accessible :code, :description, :name, :element_type, :affects

  # create affects if present
  after_create :create_affects, if: :affects

  def create_affects
    request = OopsRequest.find(oops_request_id) # otherwise request is nil :-(
    self.symbols = request.ontology_version.ontology.symbols.
      where(iri: affects).all
  end
end

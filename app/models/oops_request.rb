class OopsRequest < ActiveRecord::Base
  
  belongs_to :ontology_version
  
  has_many :responses, class_name: 'OopsResponse' do
    
    # must be called with a list of Oops::Respose::Element objects
    def create_by_elements(elements)
      transaction do
        delete_all
        elements.each {|e| create_by_element(e) }
      end
    end
    
    # expects a Oops::Respose::Element
    def create_by_element(e)
      create! \
        code:         e.code,
        name:         e.name,
        element_type: e.type,
        description:  e.description
    end
  end
  
  after_create :run, if: ->{ responses.empty? }
  
  attr_accessible :last_error, :state
  
  # executes the request and saves the returned elements
  def run
    responses.create_by_elements(execute_request)
  end
  
  def execute_request
    Oops::Client.request(ontology_version.url)
  end
  
end

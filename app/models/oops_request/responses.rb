module OopsRequest::Responses
  extend ActiveSupport::Concern

  included do
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
          description:  e.description,
          affects:      e.affects
      end
    end

  end

  protected

  # executes the request and saves the returned elements
  def execute_and_save
    responses.create_by_elements(execute)
  end

  def execute
    if Rails.env.development?
      r = Oops::Client.request :content => ontology_version.raw_data
    else
      r = Oops::Client.request :url => ontology_version.url
    end
  end

end

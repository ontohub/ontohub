module OntologyVersion::OopsRequests
  extend ActiveSupport::Concern

  included do
    has_one :request, class_name: 'OopsRequest'
  end

  def oops_request_creatable?
    request.nil? || request.state == 'failed'
  end

  def create_oops_request!
    raise "request is pending" unless oops_request_creatable?

    request.try(:destroy)
    build_request.save!
  end

end

class Api::V1::OntologyVersionsController < Api::V1::Base
  include PlainTextDefaultHelper

  inherit_resources
  defaults collection_name: :versions, finder: :find_by_number!
  belongs_to :ontology

  actions :index, :show
  respond_to :text, only: %i(show)

  def show
    super do |format|
      format.text { send_download }
    end
  end

  private
  def send_download
    render text: resource.file_in_repository.content,
           content_type: Mime::Type.lookup('application/force-download')
  end

  def default_serializer_options
    {each_serializer: OntologyVersionSerializer::Reference}
  end
end

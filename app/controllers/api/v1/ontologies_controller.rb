class Api::V1::OntologiesController < Api::V1::Base
  inherit_resources
  actions :show
  before_filter :set_format

  respond_to :text, only: %i(show)

  def show
    super do |format|
      format.json { render json: resource, serializer: OntologySerializer }
      format.text { send_download }
    end
  end

  private
  def send_download
    asset = version || resource
    render text: asset.file_in_repository.content,
           content_type: Mime::Type.lookup('application/force-download')
  end

  def version
    finder = OntologyVersionFinder.new(params[:reference], resource)
    @version ||= finder.find if params[:reference]
  end

  def set_format
    request.format = :text unless request.format.to_sym == :json
  end
end

class Api::V1::LogicsController < Api::V1::Base
  inherit_resources
  defaults finder: :find_by_slug!

  actions :show
  respond_to :xml, :rdf, only: %i(show)

  def show
    super do |format|
      format.xml do
        render :show, content_type: 'application/rdf+xml'
      end
      format.rdf do
        render 'show.xml', content_type: 'application/rdf+xml'
      end
    end
  end
end

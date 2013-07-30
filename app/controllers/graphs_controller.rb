class GraphsController < ApplicationController
  respond_to :json
  inherit_resources
  belongs_to :logic, :ontology, polymorphic: true

  def index
    respond_to do |format|
      depth = params[:depth] ? params[:depth] : 3
      fetcher = GraphDataFetcher.new(center: parent, depth: depth)
      nodes, edges = fetcher.fetch
      data = {nodes: nodes, edges: edges, center: parent}
      format.json do
        respond_with data
      end
    end
  end

end

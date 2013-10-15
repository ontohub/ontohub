class GraphsController < ApplicationController
  respond_to :json, :html
  inherit_resources
  belongs_to :logic, :ontology, :single_ontology, :distributed_ontology, polymorphic: true

  before_filter :content_kind

  def index
    respond_to do |format|
      @ontology = parent if parent.is_a?(Ontology)
      @depth = params[:depth] ? params[:depth].to_i : 3
      format.html
      format.json do
        fetcher = GraphDataFetcher.new(center: parent, depth: @depth)
        nodes, edges = fetcher.fetch
        nodes_aggregate = nodes.reduce({}) do |mem, node|
          mem[node.id] = node.aggregate
          mem
        end
        # edges_aggregate = edges.reduce({}) do |mem, edge|
        #   mem[edge.id] = edge.aggregate
        #   mem
        # end
        data = {nodes: nodes,
                edges: edges,
                center: parent,
                node_url: nodes.any? ? url_for(nodes.first.class) : nil,
                edge_url: edges.any? ? url_for(edges.first.class) : nil,
                edge_type: GraphDataFetcher.link_for(nodes.first.class),
                nodes_aggregate: nodes_aggregate }
        respond_with data
      end
    end
  end

  protected

  def content_kind
    @content_kind = :ontologies
  end

end

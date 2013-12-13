class GraphsController < InheritedResources::Base

  respond_to :json, :html
  belongs_to :logic, :ontology, :single_ontology, :distributed_ontology, polymorphic: true
  before_filter :check_read_permissions

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
        chain = resource_chain
        if chain.empty?
          chain << nodes.first.class
        else
          chain[-1] = nodes.first.class
        end
        data = {nodes: nodes,
                edges: edges,
                center: parent,
                node_url: nodes.any? ? url_for(chain) : nil,
                edge_url: edges.any? ? url_for(edges.first.class) : nil,
                edge_type: GraphDataFetcher.link_for(parent.class),
                nodes_aggregate: nodes_aggregate }
        respond_with data
      end
    end
  end

  protected

  def check_read_permissions
    authorize! :show, parent.repository if parent.is_a? Ontology
  end
end

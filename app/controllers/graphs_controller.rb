class GraphsController < InheritedResources::Base

  respond_to :json, :html
  belongs_to :ontology, :single_ontology, :distributed_ontology, polymorphic: true
  belongs_to :logic, finder: :find_by_slug!, polymorphic: true
  before_filter :check_read_permissions

  def index
    respond_to do |format|
      @ontology = parent if parent.is_a?(Ontology)
      @depth = params[:depth] ? params[:depth].to_i : 3
      format.html
      format.json { respond_with graph_data }
    end
  end

  protected

  def check_read_permissions
    authorize! :show, parent.repository if parent.is_a? Ontology
  end

  def graph_data
    {
      nodes: populate_with(nodes, :iri),
      edges: edges,
      center: populate_with(parent, :iri),
      node_url: nodes.any? ? url_for(graph_resource_chain) : nil,
      edge_url: edges.any? ? url_for(edges.first.class) : nil,
      edge_type: GraphDataFetcher.mapping_for(parent.class),
      nodes_aggregate: nodes_aggregate,
    }
  end

  def populate_with(items, *attributes)
    if items.is_a?(ActiveRecord::Relation)
      items.map { |item| populate_with(item, *attributes) }
    else
      original_item = items
      item = items.as_json.dup
      attributes.each do |attribute|
        if original_item.respond_to?(attribute) && !item.key?(attribute.to_s)
          item = item.merge(attribute.to_s => original_item.send(attribute))
        else
          item
        end
      end
      item
    end
  end

  def nodes_aggregate
    @nodes_aggregate ||= nodes.reduce({}) do |mem, node|
      mem[node.id] = node.aggregate
      mem
    end
  end

  def graph_resource_chain
    chain = resource_chain
    if chain.empty?
      chain << nodes.first.class
    else
      chain[-1] = nodes.first.class
    end
  end

  def nodes
    @fetch_result ||= GraphDataFetcher.new(center: parent, depth: @depth).fetch
    @fetch_result.first
  end

  def edges
    @fetch_result ||= GraphDataFetcher.new(center: parent, depth: @depth).fetch
    @fetch_result.last
  end
end

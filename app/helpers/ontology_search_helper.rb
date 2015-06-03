module OntologySearchHelper
  def render_filter(klass, include_blank = '', selected_key: nil)
    name = klass.name.underscore.to_sym
    render 'shared/ontology_search_filter',
      name: name,
      filter: filter_list_for(klass),
      include_blank: include_blank,
      selected: params[selected_key]
  end

  def filter_list_for(klass)
    if @repository_id
      klass.not_empty.where(ontologies: {repository_id: @repository_id})
    else
      klass.not_empty
    end
  end
end

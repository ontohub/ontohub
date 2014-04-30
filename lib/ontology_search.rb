require 'json'

# Beware! This is not tested well.
class OntologySearch
  class Response < Struct.new(:page, :ontologiesPerPage, :ontologiesInSet, :ontologies)
  end

  def initialize
    @limit = 20
  end

  def make_filters_map_json
    JSON.generate make_filters_map
  end

  def make_repository_restrictions_json(repository, prefix)
    JSON.generate make_repository_restrictions(repository, prefix)
  end

  def make_global_restrictions_json(prefix)
    JSON.generate({text: prefix})
  end

  def make_filters_map
    filters_map = {
      'OntologyType' => [
        {'name' => 'Ontologies', 'value' => nil, 'count' => 0},
        *types
      ],
      'Repository' => [
        {'name' => 'in all repositories', 'value' => nil, 'count' => 0},
        *repositories
      ],
      'Project' => [
        {'name' => 'from all projects', 'value' => nil, 'count' => 0},
        *projects
      ],
      'FormalityLevel' => [
        {'name' => 'in any formality', 'value' => nil, 'count' => 0},
        *formalities
      ],
      'LicenseModel' => [
        {'name' => 'under any license', 'value' => nil, 'count' => 0},
        *licenses
      ],
      'Task' => [
        {'name' => 'for any purpose', 'value' => nil, 'count' => 0},
        *tasks
      ]
    }
  end

  def make_repository_restrictions(repository, prefix)
    text_list = []
    
    ontology_names = repository.ontologies
      .select(:name)
      .where('name ilike ?', "#{prefix}%")
      .group(:name)
      .limit(5)
      .pluck(:name)

    ontology_names.map { |name| text_list << name }

    Entity.collect_restrictions(prefix, repository).each do |symbol|
      %i[display_name name text].each do |method|
        value = symbol.call method
        text_list << value if value
      end
    end

    ontology_ids = repository.ontologies.pluck(:id)

    logics = Logic.where('name ILIKE ?', "#{prefix}%").limit(5)
    logics.each do |logic|
      ids = logic.ontologies.pluck(:id)
      text_list << logic.name unless (ontology_ids & ids).empty?
    end

    text_list.sort.map { |x| {text: x} }
  end

  def check_restrictions(restrictions)
    restrictions.each do |restriction|
      unless restriction.is_a?(Hash)
        raise ArgumentError, 'a restriction was not a hash'
      end
      if restriction['type'].nil?
        raise ArgumentError, 'a restriction had no specified type'
      end
    end
  end

  def make_bean_list_json(repository, restrictions, page)
    check_restrictions(restrictions)
    JSON.generate(make_bean_list_response(repository, restrictions, page))
  end

  def select_items(restrictions, type_name)
    items = Array.new

    restrictions.each do |restriction|
      if restriction['type'] == type_name
        items.push restriction['item']
      end
    end

    items
  end

  def select_item(restrictions, type_name, type)
    restrictions.each do |restriction|
      if restriction['type'] == type_name
        if restriction['item'].nil?
          return nil
        else
          return type.find_by_id(restriction['item'].to_i)
        end
      end
    end

    nil
  end

  def make_bean_list_response(repository, restrictions, page)
    identifiers = select_items(restrictions, 'Mixed')

    properties = Hash.new
    properties[:repository] = repository
    properties[:ontology_type] = select_item(restrictions, 'OntologyType', OntologyType)
    properties[:project] = select_item(restrictions, 'Project', Project)
    properties[:formality_level] = select_item(restrictions, 'FormalityLevel', FormalityLevel)
    properties[:license_model] = select_item(restrictions, 'LicenseModel', LicenseModel)
    properties[:task] = select_item(restrictions, 'Task', Task)

    bean_list_factory = OntologyBeanListFactory.new

    search = Ontology.search_by_keywords(identifiers, page, properties)
    search.results.each do |ontology|
      bean_list_factory.add_small_bean(ontology)
    end

    Response.new(page, @limit, search.total, bean_list_factory.bean_list)
  end

  private

  def model_to_filters_map(model, name_proc)
    model
      .select([:name, :id])
      .order(:name)
      .all
      .map do |item|
        {
          'name'  => name_proc.call(item),
          'value' => item.id.to_s,
          'count' => item.ontologies.count
        }
      end
  end

  def types
    model_to_filters_map OntologyType,
      ->(x) {x.name.sub(/Ontology/, 'ontologies')}
  end

  def repositories
    model_to_filters_map Repository,
      ->(x) {'in ' + x.name}
  end

  def projects
    model_to_filters_map Project,
      ->(x) {'from ' + x.name }
  end

  def formalities
    model_to_filters_map FormalityLevel,
      ->(x) {'in ' + x.name}
  end

  def licenses
    model_to_filters_map LicenseModel,
      ->(x) {'under ' + x.name}
  end

  def tasks
    model_to_filters_map Task,
      ->(x) {'for ' + x.name[0..-5].from_titlecase_to_spacedlowercase}
  end
end

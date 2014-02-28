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

  def make_repository_keyword_list_json(repository, prefix)
    JSON.generate make_repository_keyword_list(repository, prefix)
  end

  def make_global_keyword_list_json(prefix)
    JSON.generate({text: prefix})
  end

  def make_filters_map
    filters_map = {
      'OntologyType' => [
        {'name' => 'Ontologies', 'value' => nil},
        *types
      ],
      'Repository' => [
        {'name' => 'in all repositories', 'value' => nil},
        *repositories
      ],
      'Project' => [
        {'name' => 'from all projects', 'value' => nil},
        *projects
      ],
      'FormalityLevel' => [
        {'name' => 'in any formality', 'value' => nil},
        *formalities
      ],
      'LicenseModel' => [
        {'name' => 'under any license', 'value' => nil},
        *licenses
      ],
      'Task' => [
        {'name' => 'for any purpose', 'value' => nil},
        *tasks
      ]
    }
  end

  def make_repository_keyword_list(repository, prefix)
    text_list = []
    
    ontology_names = repository.ontologies
      .select(:name)
      .where('name ilike ?', "#{prefix}%")
      .group(:name)
      .limit(5)
      .pluck(:name)

    ontology_names.map { |name| text_list << name }

    Entity.collect_keywords(prefix, repository).each do |symbol|
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

  def make_bean_list_json(repository, keyword_list, page)
    JSON.generate(make_bean_list_response(repository, keyword_list, page))
  end

  def select_item_list(keyword_list, type_name)
    item_list = Array.new

    keyword_list.each do |keyword|
      if keyword["type"] == type_name
        item_list.push keyword["item"]
      end
    end

    item_list
  end

  def select_item(keyword_list, type_name, type)
    keyword_list.each do |keyword|
      if keyword["type"] == type_name
        if keyword["item"].nil?
          return nil
        else
          return type.find_by_id(keyword["item"].to_i)
        end
      end
    end

    nil
  end

  def make_bean_list_response(repository, keyword_list, page)
    mixed_list = select_item_list(keyword_list, 'Mixed')

    qualifiers = Hash.new
    qualifiers[:repository] = repository
    qualifiers[:ontology_type] = select_item(keyword_list, 'OntologyType', OntologyType)
    qualifiers[:project] = select_item(keyword_list, 'Project', Project)
    qualifiers[:formality_level] = select_item(keyword_list, 'FormalityLevel', FormalityLevel)
    qualifiers[:license_model] = select_item(keyword_list, 'LicenseModel', LicenseModel)
    qualifiers[:task] = select_item(keyword_list, 'Task', Task)

    bean_list_factory = OntologyBeanListFactory.new

    search = Ontology.search_by_keywords(mixed_list, page, qualifiers)
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
          'value' => item.id.to_s
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

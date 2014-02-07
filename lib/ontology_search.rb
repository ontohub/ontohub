require 'json'

#
# Beware! This is not tested well.
#
class OntologySearch

  class Response < Struct.new(:page,:ontologiesPerPage,:ontologiesInSet,:ontologies)
  end

  def initialize
    @limit = 20
  end

  def make_filters_map_json()
    JSON.generate(make_filters_map())
  end

  def make_repository_keyword_list_json(repository, prefix)
    JSON.generate(make_repository_keyword_list(repository, prefix))
  end

  def make_global_keyword_list_json(prefix)
    JSON.generate(make_global_keyword_list(prefix))
  end

  def make_filters_map()
    types = OntologyType.select([:name, :id]).order(:name).all.map {|type| {"name" => type.name.sub(/Ontology/, "ontologies"), "value" => type.id.to_s} }
    repositories = Repository.select([:name, :id]).order(:name).all.map {|repository| {"name" => "in " + repository.name, "value" => repository.id.to_s} }
    projects = Project.select([:name, :id]).order(:name).all.map {|project| {"name" => "from " + project.name, "value" => project.id.to_s} }
    formalities = FormalityLevel.select([:name, :id]).order(:name).all.map {|formality| {"name" => "in " + formality.name, "value" => formality.id.to_s} }
    licenses = LicenseModel.select([:name, :id]).order(:name).all.map {|license| {"name" => "under " + license.name, "value" => license.id.to_s} }
    tasks = Task.select([:name, :id]).order(:name).all.map {|task| {"name" => "for " + task.name[0..-5].from_titlecase_to_spacedlowercase, "value" => task.id.to_s} }
    filters_map = {
      'OntologyType' => [
        { "name" => 'Ontologies', "value" => nil },
        *types
      ],
      'Repository' => [
        { "name" => 'in all repositories', "value" => nil },
        *repositories
      ],
      'Project' => [
        { "name" => 'from all projects', "value" => nil },
        *projects
      ],
      'FormalityLevel' => [
        { "name" => 'in any formality', "value" => nil },
        *formalities
      ],
      'LicenseModel' => [
        { "name" => 'under any license', "value" => nil },
        *licenses
      ],
      'Task' => [
        { "name" => 'for any purpose', "value" => nil },
        *tasks
      ]
    }
  end

  def make_repository_keyword_list(repository, prefix)
    text_list = Set.new
    
    #unless repository.ontologies.where("name = :prefix", prefix: prefix, repository_id: repository).empty?
    #  text_list.add(prefix)
    #end
    
    repository.ontologies.select(:name).where("name ILIKE :prefix", prefix: "#{prefix}%").limit(25).group("name").limit(5).each do |ontology|
      text_list.add(ontology.name)
    end

    Entity.collect_keywords(prefix, repository).each do |symbol|
      text_list.add(symbol.display_name) if symbol.display_name
      text_list.add(symbol.name) if symbol.name
      text_list.add(symbol.text) if symbol.text
    end

    ontology_ids = Set.new
    repository.ontologies.select(:id).each do |ontology|
      ontology_ids.add(ontology.id)
    end

    Logic.where("name ILIKE :prefix", prefix: "#{prefix}%").limit(5).each do |logic|
       logic_ontology_ids = Set.new
       logic.ontologies.each do |ontology|
         logic_ontology_ids.add(ontology.id)
       end
       if (ontology_ids & logic_ontology_ids).size != 0
         text_list.add(logic.name)
       end
    end

    text_list.to_a.sort.map { |x| {text: x} }
  end

  def make_global_keyword_list(prefix)
    text_list = Set.new
    text_list.add(prefix)
    text_list.to_a.sort.map { |x| {text: x} }
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
    ontology_type = select_item(keyword_list, 'OntologyType', OntologyType)
    project = select_item(keyword_list, 'Project', Project)
    formality_level = select_item(keyword_list, 'FormalityLevel', FormalityLevel)
    license_model = select_item(keyword_list, 'LicenseModel', LicenseModel)
    task = select_item(keyword_list, 'Task', Task)

    bean_list_factory = OntologyBeanListFactory.new
    search = Ontology.search_by_keywords(mixed_list, page, repository, project, ontology_type, formality_level, license_model, task)
    search.results.each do |ontology|
      bean_list_factory.add_small_bean(ontology)
    end

    Response.new(page, @limit, search.total, bean_list_factory.bean_list)
  end

end

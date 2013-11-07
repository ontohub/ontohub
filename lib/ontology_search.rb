require 'json'

#
# Beware! This is not tested well.
#
class OntologySearch

  def initialize
    @limit = 20
  end

  def make_repository_keyword_list_json(repository, prefix)
    JSON.generate(make_repository_keyword_list(repository, prefix))
  end

  def make_global_keyword_list_json(prefix)
    JSON.generate(make_global_keyword_list(prefix))
  end

  def make_repository_keyword_list(repository, prefix)
    text_list = Set.new
    
    unless repository.ontologies.where("name = :prefix", prefix: prefix, repository_id: repository).empty?
      text_list.add(prefix)
    end
    
    repository.ontologies.select(:name).where("name ILIKE :prefix", prefix: "#{prefix}%").group("name").limit(5).each do |ontology|
      text_list.add(ontology.name)
    end

    ontologies = repository.ontologies
    ontology_ids = Set.new
    ontologies.each do |ontology|
      ontology.entities.select("display_name, name").where("display_name ILIKE :prefix or name ILIKE :prefix", prefix: "#{prefix}%").group("display_name, name").limit(5).each do |symbol|
        text_list.add(symbol.display_name) if symbol.display_name
        text_list.add(symbol.name) if symbol.display_name.nil?
      end
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

    unless Ontology.where("name = :prefix", prefix: prefix).empty?
      text_list.add(prefix)
    end

    unless Entity.where("display_name ILIKE :prefix or name ILIKE :prefix", prefix: prefix).empty?
      text_list.add(prefix)
    end

    Ontology.select(:name).where("name ILIKE :prefix", prefix: "#{prefix}%").group("name").limit(5).each do |ontology|
      text_list.add(ontology.name)
    end

    Entity.select("display_name, name").where("display_name ILIKE :prefix or name ILIKE :prefix", prefix: "#{prefix}%").group("display_name, name").limit(5).each do |symbol|
      text_list.add(symbol.display_name) if symbol.display_name
      text_list.add(symbol.name) if symbol.display_name.nil?
    end

    Logic.where("name ILIKE :prefix", prefix: "#{prefix}%").limit(5).each do |logic|
      if logic.ontologies.size != 0
        text_list.add(logic.name)
      end
    end

    text_list.to_a.sort.map { |x| {text: x} }
  end

  def make_repository_bean_list_json(repository, keyword_list, page)
    JSON.generate(make_repository_bean_list_response(repository, keyword_list, page))
  end

  def make_global_bean_list_json(keyword_list, page)
    JSON.generate(make_global_bean_list_response(keyword_list, page))
  end

  def make_repository_bean_list_response(repository, keyword_list, page)
    bean_list_factory = OntologyBeanListFactory.new
    search = Ontology.search_by_keywords_in_repository(keyword_list, page, repository)
    search.results.each do |ontology|
      bean_list_factory.add_small_bean(ontology)
    end
    bean_list_factory.bean_list
    {
      page: page,
      resultsInPage: 20,
      resultsInSet: search.total,
      results: bean_list_factory.bean_list
    }
  end

  def make_global_bean_list_response(keyword_list, page)
    {
      page: 0,
      resultsInPage: 50,
      resultsInSet: 0,
      results: make_global_bean_list(keyword_list, page)
    }
  end

  def make_global_bean_list(keyword_list, page)
    bean_list_factory = OntologyBeanListFactory.new
    Ontology.search_by_keywords(keyword_list, page).results.each do |ontology|
      bean_list_factory.add_small_bean(ontology)
    end
    bean_list_factory.bean_list
  end

end

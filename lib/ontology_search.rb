require 'json'

#
# Beware! This is not tested well.
#
class OntologySearch

  class Response < Struct.new(:page,:resultsInPage,:resultsInSet,:results)
  end

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

    unless Ontology.where("name = :prefix", prefix: prefix).empty?
      text_list.add(prefix)
    end

    unless Entity.where("display_name ILIKE :prefix or name ILIKE :prefix", prefix: prefix).empty?
      #text_list.add(prefix)
    end

    Ontology.select(:name).where("name ILIKE :prefix", prefix: "#{prefix}%").group("name").limit(5).each do |ontology|
      text_list.add(ontology.name)
    end

    Entity.select("display_name").where("display_name ILIKE :prefix", prefix: "#{prefix}%").group("display_name").limit(5).each do |symbol|
      text_list.add(symbol.display_name)
    end

    Entity.select("name").where("name ILIKE :prefix", prefix: "#{prefix}%").group("name").limit(5).each do |symbol|
      text_list.add(symbol.name)
    end

    Entity.select("text").where("text ILIKE :prefix", prefix: "#{prefix}%").group("text").limit(5).each do |symbol|
      text_list.add(symbol.text)
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
    # Display all repository ontologies for empty keyword list
    if keyword_list.size == 0
      offset = (page - 1) * @limit
      bean_list_factory = OntologyBeanListFactory.new
      repository.ontologies.limit(@limit).offset(offset).each do |ontology|
        bean_list_factory.add_small_bean(ontology)
      end
      return Response.new(page, @limit, repository.ontologies.count, bean_list_factory.bean_list)
    end

    index = 0
    bean_list_factory = OntologyBeanListFactory.new
    search = Ontology.search_by_keywords_in_repository(keyword_list, page, repository)
    search.results.each do |ontology|
      bean_list_factory.add_small_bean(ontology)
    end

    Response.new(page, @limit, search.total, bean_list_factory.bean_list)
  end

  def make_global_bean_list_response(keyword_list, page)

    # Display all ontologies for empty keyword list
    if keyword_list.size == 0
      offset = (page - 1) * @limit
      bean_list_factory = OntologyBeanListFactory.new
      Ontology.limit(@limit).offset(offset).each do |ontology|
        bean_list_factory.add_small_bean(ontology)
      end
      return Response.new(page, @limit, Ontology.count, bean_list_factory.bean_list)
    end

    bean_list_factory = OntologyBeanListFactory.new
    search = Ontology.search_by_keywords(keyword_list, page)
    search.results.each do |ontology|
      bean_list_factory.add_small_bean(ontology)
    end

    Response.new(page, @limit, search.total, bean_list_factory.bean_list)
  end

end

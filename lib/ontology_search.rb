require 'json'

#
# Beware! This is not tested well.
#
class OntologySearch

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
    
    unless Entity.where("name = :prefix", prefix: prefix).empty?
      #TODO Search only symbols of ontologies of the repository
      #text_list.add(prefix)
    end

    repository.ontologies.select(:name).where("name ILIKE :prefix", prefix: "#{prefix}%").group("name").limit(5).each do |ontology|
      text_list.add(ontology.name)
    end

    repository.ontologies.each do |ontology|
      ontology.entities.select(:name).where("name ILIKE :prefix", prefix: "#{prefix}%").group("name").limit(5).each do |symbol|
        text_list.add(symbol.name)
      end
    end

    Logic.select(:name).where("name ILIKE :prefix", prefix: "#{prefix}%").limit(5).each do |logic|
      text_list.add(logic.name)
    end

    text_list.to_a.sort.map { |x| {text: x} }
  end

  def make_global_keyword_list(prefix)
    text_list = Set.new

    unless Ontology.where("name = :prefix", prefix: prefix).empty?
      text_list.add(prefix)
    end

    unless Entity.where("name = :prefix", prefix: prefix).empty?
      text_list.add(prefix)
    end

    Ontology.select(:name).where("name ILIKE :prefix", prefix: "#{prefix}%").group("name").limit(5).each do |ontology|
      text_list.add(ontology.name)
    end

    Entity.select(:name).where("name ILIKE :prefix", prefix: "#{prefix}%").group("name").limit(5).each do |symbol|
      text_list.add(symbol.name)
    end

    Logic.select(:name).where("name ILIKE :prefix", prefix: "#{prefix}%").limit(5).each do |logic|
      text_list.add(logic.name)
    end

    text_list.to_a.sort.map { |x| {text: x} }
  end


  def make_repository_bean_list_json(repository, keyword_list)
    JSON.generate(make_repository_bean_list(repository, keyword_list))
  end

  def make_global_bean_list_json(keyword_list)
    JSON.generate(make_global_bean_list(keyword_list))
  end


  def make_repository_bean_list(repository, keyword_list)
    ontology_hash = Hash.new
    index = 0

    keyword_list.each do |keyword|
      keyword_hash = Hash.new

      repository.ontologies.where("name = :name", name: "#{keyword}").limit(50).each do |ontology|
        keyword_hash[ontology.id] ||= ontology
      end

      Entity.where("name = :name", name: "#{keyword}").limit(50).each do |symbol|
        if repository.id == symbol.ontology.repository.id
          keyword_hash[symbol.ontology.id] ||= symbol.ontology
        end
      end

      if logic = Logic.find_by_name(keyword)
        logic.ontologies.each { |o| keyword_hash[o.id] ||= o }
      end

      if index == 0
        ontology_hash = keyword_hash
      else
        hash = Hash.new

        keyword_hash.each_key do |key|
          hash[key] ||= ontology_hash[key] if ontology_hash[key]
        end

        ontology_hash = hash
      end

      index += 1
    end

    bean_list_factory = OntologyBeanListFactory.new
    ontology_hash.each_value do |ontology|
      bean_list_factory.add_small_bean(ontology)
    end

    bean_list_factory.bean_list
  end

  def make_global_bean_list(keyword_list)
    ontology_hash = Hash.new
    index = 0

    keyword_list.each do |keyword|
      keyword_hash = Hash.new

      Ontology.where("name = :name", name: "#{keyword}").limit(50).each do |ontology|
        keyword_hash[ontology.id] ||= ontology
      end

      Entity.where("name = :name", name: "#{keyword}").limit(50).each do |symbol|
        keyword_hash[symbol.ontology.id] ||= symbol.ontology
      end

      if logic = Logic.find_by_name(keyword)
        logic.ontologies.each { |o| keyword_hash[o.id] ||= o }
      end

      if index == 0
        ontology_hash = keyword_hash
      else
        hash = Hash.new

        keyword_hash.each_key do |key|
          hash[key] ||= ontology_hash[key] if ontology_hash[key]
        end

        ontology_hash = hash
      end

      index += 1
    end

    bean_list_factory = OntologyBeanListFactory.new
    ontology_hash.each_value do |ontology|
      bean_list_factory.add_small_bean(ontology)
    end

    bean_list_factory.bean_list
  end

end

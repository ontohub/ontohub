require 'json'

class OntologySearch

  def initialize()
  end

  def makeKeywordListJson(prefix)
    keywordList = makeKeywordList(prefix)
    return JSON.generate(keywordList)
  end

  def makeKeywordList(prefix)
    textList = Set.new
    textList.add(prefix) unless Ontology.where("name = :prefix", prefix: prefix).length == 0
    textList.add(prefix) unless Entity.where("name = :prefix", prefix: prefix).length == 0
    Ontology.select(:name).where("name ILIKE :prefix", prefix: "#{prefix}%").group("name").limit(5).each do |ontology|
      textList.add(ontology.name)
    end
    Entity.select(:name).where("name ILIKE :prefix", prefix: "#{prefix}%").group("name").limit(5).each do |symbol|
      textList.add(symbol.name)
    end
    Logic.select(:name).where("name ILIKE :prefix", prefix: "#{prefix}%").limit(5).each do |logic|
      textList.add(logic.name)
    end
    textList = textList.to_a();
    textList = textList.sort
    keywordListFactory = KeywordListFactory.new()
    textList.each do |text|
      keywordListFactory.addKeyword(text)
    end
    keywordList = keywordListFactory.getKeywordList()
    return keywordList
  end

  def makeBeanListJson(keywordList)
    beanList = makeBeanList(keywordList)
    return JSON.generate(beanList)
  end

  def makeBeanList(keywordList)
    ontologyHash = Hash.new
    index = 0
    keywordList.each do |keyword|
      keywordHash = Hash.new
      Ontology.where("name = :name", name: "#{keyword}").limit(50).each do |ontology|
        if (keywordHash[ontology.id].nil?)
          keywordHash[ontology.id] = ontology
        end
      end
      Entity.where("name = :name", name: "#{keyword}").limit(50).each do |symbol|
        if (keywordHash[symbol.ontology.id].nil?)
          keywordHash[symbol.ontology.id] = symbol.ontology
        end
      end
      logic = Logic.find_by_name(keyword)
      if logic
        logic.ontologies.each do |ontology|
          if (keywordHash[ontology.id].nil?)
            keywordHash[ontology.id] = ontology
          end
        end
      end
      if (index == 0)
        ontologyHash = keywordHash
      else
        hash = Hash.new
        keywordHash.each_key do |key|
          if (!ontologyHash[key].nil?)
            hash[key] = ontologyHash[key]
          end
        end
        ontologyHash = hash
      end
      index = index + 1
    end
    beanListFactory = OntologyBeanListFactory.new()
    ontologyHash.each_value do |ontology|
      beanListFactory.addSmallBean(ontology)
    end
    beanList = beanListFactory.getBeanList()
    return beanList
  end

end

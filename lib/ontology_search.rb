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
    Ontology.where("name LIKE :prefix", prefix: "#{prefix}%").each do |ontology|
      textList.add(ontology.name)
    end
    Entity.where("name LIKE :prefix", prefix: "#{prefix}%").each do |symbol|
      textList.add(symbol.name)
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

  def makeSmallBeanList()

  end

end

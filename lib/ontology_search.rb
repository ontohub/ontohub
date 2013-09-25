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
    Ontology.select(:name).where("name LIKE :prefix", prefix: "#{prefix}%").group("name").limit(50).each do |ontology|
      textList.add(ontology.name)
    end
    Entity.select(:name).where("name LIKE :prefix", prefix: "#{prefix}%").group("name").limit(50).each do |symbol|
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

  def makeBeanListJson(keywordList)
    beanList = makeBeanList(keywordList)
    return JSON.generate(beanList)
  end

  def makeBeanList(keywordList)
    beanListFactory = OntologyBeanListFactory.new()
    keywordList.each do |keyword|
      Ontology.where("name = :name", name: "#{keyword}").limit(50).each do |ontology|
        beanListFactory.addSmallBean(ontology)
      end
      Entity.where("name = :name", name: "#{keyword}").limit(50).each do |symbol|
        beanListFactory.addSmallBean(symbol.ontology)
      end
    end
    beanList = beanListFactory.getBeanList()
    return beanList
  end

end

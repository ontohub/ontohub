require 'json'

class KeywordListFactory

  def initialize()
    @keywordList = []
  end

  def addKeyword(text)
    keyword = makeKeyword(text)
    @keywordList.push(keyword)
  end

  def makeKeyword(text)
    return {text: text}
  end

  def getKeywordList()
    return @keywordList
  end

end


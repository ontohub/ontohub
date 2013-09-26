module SentenceHelper

  ### Some sentences have their very own name appended to the text. This method removes it for readability purposes

  def text_stripper(sentence)
    "#{sentence.text}".sub(/\s%\(#{sentence.name}\)%/, '')
  end

end

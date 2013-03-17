module SentenceHelper
  def text_stripper(sentence)
    "#{sentence.text}".sub(/\s%\(#{sentence.name}\)%/, '')
  end
end

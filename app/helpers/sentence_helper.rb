module SentenceHelper

  def format_for_view(sentence)
    if sentence.display_text? then
      sentence.display_text.gsub(/<(\S*)>/, "<strong>\\1</strong>" ).html_safe
    else
      "#{sentence.text}".sub(/\s%\(#{sentence.name}\)%/, '')
    end
  end

end

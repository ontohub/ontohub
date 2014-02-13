module SentenceHelper

  def format_for_view(sentence)
    if sentence.display_text? then
      sentence.display_text.gsub(/<(\S*)>/, "<strong>\\1</strong>" ).html_safe
    else
      "#{sentence.text}".sub(/\s%\(#{sentence.name}\)%/, '')
    end
  end

  def link_to_sentence_origin(sentence, ontology)
    if sentence.ontology != ontology
      t('.defined_in', link: link_to(sentence.ontology,
                [sentence.ontology.repository, sentence.ontology]))
    end
  end

end

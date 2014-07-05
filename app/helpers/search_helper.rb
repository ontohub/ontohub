module SearchHelper

  def hit_highlight(hit, field)
    highlight = hit.highlight(field)
    if highlight
      # does not escape special characters outside the matches :-(
      #highlight.format { |word| "<span class=\"highlight\">#{h word}</span>" }

      html = h highlight.format { |word| "#BEGIN##{word}#END#" }
      html.gsub( /#BEGIN#(.+?)#END#/, "<span class='highlight'>\\1</span>" ).html_safe
    else
      hit.result.send field
    end
  end

end

module SearchHelper
  
  def hit_highlight(hit, key)
    if highlight = hit.highlight(key)
      highlight.format{ |word| "<span class='highlight'>#{h word}</span>" }.html_safe
    else
      hit.result.send(key)
    end
  end
  
end

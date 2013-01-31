module EntityHelper
  def text_with_highlighted_fragment(entity)
    return entity.text unless entity.fragment_name

    # Substitute < and > by HTML entities,
    # substitute fragment by <strong>: fragment.
    #
    # "highlight entity.text, entity.fragment_name"
    # or similar would have been more elegant, but we could not get it working.
    entity.text
      .gsub(/[\<\>]/, {'<' => '&lt;', '>' => '&gt;'})
      .gsub(/#(#{entity.fragment_name})/, '#' + content_tag(:strong, entity.fragment_name))
      .html_safe
  end
end

module EntityHelper
  def highlighted_fragment(entity)
    return entity.text unless entity.fragment_name
    entity.text.gsub(/#{entity.fragment_name}/, content_tag(:strong, entity.fragment_name).html_safe)
  end
end

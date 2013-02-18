module EntityHelper
  def name_highlighter(entity)
    h(entity.text).gsub(/#{entity.name}/, (content_tag(:strong,entity.name))).html_safe
  end
end

module EntityHelper
  def name_highlighter(entity)
    h(entity.text).gsub(/\b#{entity.name}\b/, (content_tag(:strong,entity.name))).html_safe
  end
end

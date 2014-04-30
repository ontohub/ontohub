module EntityHelper
  
  def show_classes?
    return params[:kind] != "Class"
  end

  def name_highlighter(entity)
    if entity.name == entity.text
      string = entity.text
    else
      string = content_tag(:strong, entity.name, class: 'entity_highlight')
    end

    h(entity.text).gsub(/\b#{entity.name}\b/, string).html_safe
  end

end

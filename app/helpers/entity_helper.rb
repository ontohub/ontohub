module EntityHelper

  def show_classes?(kind=params[:kind])
    kind == "Class"
  end

  def name_highlighter(entity)
    if entity.name == entity.text
      string = entity.text
    else
      string = content_tag(:strong, entity.name, class: 'entity_highlight')
    end

    h(entity.text).gsub(/\b#{entity.name}\b/, string).html_safe
  end

  def choose_default_entity_kind(entity_kinds)
    raw_entity_kinds = entity_kinds.map { |e| e.try(:kind) || e.to_s }
    if raw_entity_kinds.include?('Class')
      'Class'
    else
      entity_kinds.first.kind
    end
  end

end

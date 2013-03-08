module EntityHelper
  def name_highlighter(entity)
    if entity.name == entity.text
      string = entity.text
    else
      string = content_tag(:span, entity.name, :class => 'entity_highlight')
    end

    string = iri_tooltip(entity, string) if entity.iri

    h(entity.text).gsub(/\b#{entity.name}\b/, string).html_safe
  end

  def iri_tooltip(entity, string)
    content_tag :span, string, :'data-original-title' => entity.iri, :class => 'entity_tooltip'
  end
end

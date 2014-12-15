module EntityHelper

  def show_classes?(kind=params[:kind])
    kind == "Class"
  end

  def name_highlighter(symbol)
    if symbol.name == symbol.text
      string = symbol.text
    else
      string = content_tag(:strong, symbol.name, class: 'symbol_highlight')
    end

    h(symbol.text).gsub(/\b#{symbol.name}\b/, string).html_safe
  end

  def choose_default_symbol_kind(symbol_kinds)
    raw_symbol_kinds = symbol_kinds.map { |e| e.try(:kind) || e.to_s }
    if raw_symbol_kinds.include?('Class')
      'Class'
    else
      symbol_kinds.first.kind
    end
  end

end

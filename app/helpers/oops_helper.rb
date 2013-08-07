module OopsHelper
  
  ICONS = {
    'Pitfall'    => :bolt,
    'Warning'    => 'warning-sign',
    'Suggestion' => :lightbulb
  }
  
  def oops_icons(response_scope)
    responses = response_scope.select('element_type, count(*) AS count').group(:element_type).order(:element_type)
    out = ''
    
    # support unknown element_types
    (ICONS.keys + responses.map(&:element_type)).uniq.each do |type|
      count = responses.find{|r| r.element_type == type }.try(:count) || 0
      
      if count == 0
        out << content_tag(:i, '', class: 'empty')
      else
        icon = ICONS[type] || 'question-sign'
        out << content_tag(:i, '', class: oops_icon(type))
      end
    end
    
    out.html_safe
  end
  
  def oops_icon(type)
    icon = ICONS[type] || 'question-sign'
    "icon-#{icon}"
  end
  
end
module CategoryHelper
  def build_dropdown(base_node)
    html= ''
    html << content_tag(:ul, :class => 'dropdown') do
      html2 = ''
      html2 << content_tag(:a, "Select level #{base_node.depth} category", :class => 'dropdown-toggle', :role => "button", :'data-toggle' => "dropdown")
      html2 << content_tag(:b,'', :class => 'caret')
      html2 << content_tag(:ul, build_menu_item(base_node), :class => 'dropdown-menu', :'data-remote' => true, :role => 'menu')
      html2.html_safe
    end
    html.html_safe
  end

  def build_menu_item(node)
    html3 = ''
    node.children.each do |child|
      html3 << content_tag(:li, link_to("#{child}", "#", :tabindex => "-1", :class => 'js-submenu', :id => child))
    end
    html3.html_safe
  end
end

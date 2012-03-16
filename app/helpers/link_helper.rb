module LinkHelper
  
  def fancy_link(resource)
    link_to resource, resource,
      'data-type' => resource.class,
      :title      => resource.respond_to?(:title) ? resource.title : nil
  end
  
  def counter_link(url, counter, subject)
    
    text = content_tag(:strong, counter || '?')
    text << content_tag(:span, counter==1 ? subject : subject.pluralize)
    
    link_to text, url
  end
  
end

module LinkHelper
  
  def counter_link(url, counter, subject)
    
    text = content_tag(:strong, counter)
    text << (counter==1 ? subject : subject.pluralize)
    
    link_to text, url
  end
  
end

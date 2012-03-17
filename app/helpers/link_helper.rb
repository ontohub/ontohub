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
  
  def format_links(*args, &block)
    options = args.extract_options!
    args    = %w(xml json) if args.empty?
    args.flatten!
    
    options[:url]  ||= {}
    
    links = ''
    links << capture_haml(&block) << ' ' if block_given?
    links << args.collect{ |f|
      content_tag :li, link_to(f.to_s.upcase, params.merge(options[:url]).merge(:format => f), :title => "Get this page as #{f.upcase}")
    }.join("")
    
    content_tag('ul', links.html_safe, :class => 'formats')
  end
  
end

module LinkHelper
  
  def sort_link_list(collection)
    hash = {}
    collection.each do |link|
        i = 0
      if link.entity_mappings.empty?
        hash["empty#{i}"] = [{link: link, target: ""}]
        i += 1
      end
         link.entity_mappings.each do |mapping|
         sym =  mapping.source.to_s.to_sym
          if hash[sym]
            hash[sym] << {link: link, target: mapping.target}
          else
            hash[sym] = [{link: link, target: mapping.target}]
          end
        end
      end
      return hash
  end
  
  def fancy_link(resource)
    clazz = resource.class
    clazz = 'Ontology' if clazz.to_s.include?('Ontology')
    data_type, value = determine_image_type(resource)
    
    unless resource.is_a? Array then

      if block_given?
        name = yield resource
      else
        name = resource
      end

      link_to name, resource,
        data_type => value,
        :title      => resource.respond_to?(:title) ? resource.title : nil
    else

      if block_given?
        name = yield resource
      else
        name = resource
      end

      link_to name, resource,
        data_type => value,
        :title      => resource.last.respond_to?(:title) ? resource.last.title : nil
    end
  end

  def determine_image_type(resource)
    return ['data-type', resource.class.to_s] unless resource.is_a?(Ontology)
    data_type = 'data-ontologyclass'
    distributed_type = ->(distributed_ontology) do
      if distributed_ontology.homogeneous?
        "distributed_homogeneous_ontology"
      else
        "distributed_heterogeneous_ontology"
      end
    end
    value = if resource.is_a?(DistributedOntology)
              distributed_type[resource]
            else
              if resource.parent
                "single_in_#{distributed_type[resource.parent]}"
              else
                'single_ontology'
              end
            end
    [data_type, value]
  end

  def ontology_link_to(resource)
    data_type, value = determine_image_type(resource)
    content_tag(:span, class: 'ontology_title') do
      link_to resource, {}, data_type => value
    end
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
    links << capture(&block) << ' ' if block_given?
    links << args.collect{ |f|
      content_tag :li, link_to(f.to_s.upcase, params.merge(options[:url]).merge(:format => f), :title => "Get this page as #{f.upcase}")
    }.join("")
    
    content_tag('ul', links.html_safe, :class => 'formats')
  end
  
end

module LinkHelper

  include ExternalMapping

  def counter_link(url, counter, subject)
    text = content_tag(:strong, counter || '?')
    text << content_tag(:span, counter == 1 ? subject : subject.pluralize)

    link_to text, url
  end

  def fancy_link(resource)
    return nil unless resource

    data_type, value = determine_image_type(resource)

    name = block_given? ? yield(resource) : resource

    title_target = resource.respond_to?(:last) ? resource.last : resource
    title = title_target.title if title_target.respond_to?(:title)

    linked_to =
      if resource.respond_to?(:locid)
        url_for(resource)
      elsif resource.is_a?(Ontology)
        repository_ontology_path(resource.repository, resource)
      else
        resource
      end

    link_to name, linked_to,
      data_type => value,
      title: title
  end

  def format_links(*args, &block)
    options = args.extract_options!
    args    = %w(xml json) if args.empty?
    args.flatten!

    options[:url] ||= {}

    links = ''
    links << capture(&block) << ' ' if block_given?
    links << args.collect do |f|
      content_tag :li, link_to(f.to_s.upcase, params.merge(options[:url]).merge(format: f), title: "Get this page as #{f.upcase}")
    end.join("")

    content_tag('ul', links.html_safe, class: 'formats')
  end

  def determine_image_type(resource)
    if resource.is_a?(Repository) && resource.is_private
      return ['data-type', "Private#{resource.class.to_s}"]
    end

    if resource.is_a?(Repository) && resource.mirror?
      return ['data-type', "Remote#{resource.class.to_s}"]
    end

    unless resource.is_a?(Ontology)
      return ['data-type', resource.class.to_s]
    end

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
      link_to resource, url_for(resource), data_type => value
    end
  end

  def wiki_link(controller, action)
    generate_external_link controller, action, 'controller', 'wiki'
  end
end

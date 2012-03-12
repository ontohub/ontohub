module OntologyHelper
  def status(resource)
    html = content_tag :span, resource.state, class: "state #{resource.state}"

    if resource.state == 'pending'
      html << image_tag('spinner-16x16.gif', class: 'state spinner')
    end

    html
  end
end

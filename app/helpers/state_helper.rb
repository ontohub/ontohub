module StateHelper
  def retry_resource_chain
    if resource.is_a?(Ontology)
      [:retry_failed, *resource_chain]
    elsif resource.is_a?(Theorem)
      [:retry_failed, *resource_chain, resource]
    elsif resource.is_a?(ProofAttempt)
      [:retry_failed, *resource_chain, resource.theorem, resource]
    else
      [:retry_failed, *resource_chain]
    end
  end

  def state_tag(resource)
    resource = resource.is_a?(Ontology) ? resource.current_version : resource

    html_opts = {
      class: "evaluation-state",
      data: {
        klass: resource.class.to_s,
        id: resource.id,
        uri: locid_for(resource),
        state: resource.state,
      }
    }
    content_tag(:small, html_opts) do
      state(resource)
    end
  end

  def state(resource)
    html = content_tag(:span, resource.state)

    unless State::TERMINAL_STATES.include?(resource.state)
      html << " " << image_tag('spinner-16x16.gif', class: 'spinner')
    end

    if resource.state == 'failed' && resource.is_a?(Ontology)
      version = resource.versions.last

      link = ' ('
      link << link_to('error',
        locid_for(resource, :ontology_versions),
        :'data-original-title' => version.last_error,
        class: 'help'
      )
      link << ')'

      html << content_tag(:span, link.html_safe, class: 'error')
    end

    html
  end
end

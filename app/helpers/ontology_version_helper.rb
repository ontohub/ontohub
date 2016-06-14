module OntologyVersionHelper
  def failed?(ontology_version)
    ontology_version.state == 'failed'
  end

  def can_edit?(ontology_version)
    can?(:write, ontology_version.repository) &&
      failed?(ontology_version) &&
      ontology_version.latest_version?
  end

  def btn_url(ontology_version)
    fancy_repository_path(resource_chain[0],
                          path: ontology_version.path,
                          ref: ontology_version.commit_oid,
                          action: :show,
                          exact_commit: !ontology_version.latest_version?)
  end

  def edit_or_view_button(ontology_version)
    editable = can_edit?(ontology_version)
    btn_text = editable ? 'Edit' : 'View'
    anchor = editable ? '#edit' : ''

    link_to btn_text,
            btn_url(ontology_version) + anchor,
            class: 'btn btn-xs btn-default'
  end

  def pusher_info(ontology_version)
    if ontology_version.pusher
      fancy_link(ontology_version.pusher)
    elsif ontology_version.commit.pusher_name.present?
      ontology_version.commit.pusher_name
    else
      '-'
    end
  end
end

module ExternalMapping

  def generate_external_link(controller, action, second_level, external_target)
    mappings = Ontohub::Application.config.external_url_mapping[external_target]
    root = mappings['root']
    target = get_mapping_for mappings, second_level, controller, action

    link_to 'Help', root + target
  end

  def get_mapping_for(mapping, *args)
    args.each do |level|
      mapping = mapping[level]
      unless mapping
        mapping = ''
        break
      end
    end

    mapping
  end

end

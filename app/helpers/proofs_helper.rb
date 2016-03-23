module ProofsHelper
  def form_url_chain
    chain = resource_chain
    chain << resource.proof_obligation if resource.theorem?
    chain << :proofs
  end

  def klass
    t("proofs.new.klass.#{resource.proof_obligation.class.to_s.underscore}")
  end

  def proving_single_theorem?
    resource.theorem?
  end

  def theorems
    if resource.theorem?
      [resource.proof_obligation]
    else
      resource.proof_obligation.theorems
    end
  end

  def checked_axiom_selection_method
    resource.axiom_selection_method || AxiomSelection::METHODS.first
  end

  def sine_value(field, default_value)
    resource.specific_axiom_selection.try(field) || default_value
  end

  def proof_timeout_label(value)
    if value >= 1.days
      normalized_value = value / 1.days
      label = t('proofs.new.timeout.day')
      "#{normalized_value} #{label.pluralize(normalized_value)}"
    elsif value >= 1.hours
      normalized_value = value / 1.hours
      label = t('proofs.new.timeout.hour')
      "#{normalized_value} #{label.pluralize(normalized_value)}"
    elsif value >= 1.minutes
      normalized_value = value / 1.minutes
      label = t('proofs.new.timeout.minute')
      "#{normalized_value} #{label.pluralize(normalized_value)}"
    else
      "#{value} #{t('proofs.new.timeout.second').pluralize(value)}"
    end
  end
end

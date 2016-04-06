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

  def proof_timeout_label(seconds)
    unit = proof_timeout_label_unit(seconds)
    normalized_timeout = seconds / 1.send(unit)
    label = t("proofs.new.timeout.#{unit}")
    "#{normalized_timeout} #{label.pluralize(normalized_timeout)}"
  end

  def proof_timeout_label_unit(seconds)
    if seconds >= 1.day
      :day
    elsif seconds >= 1.hour
      :hour
    elsif seconds >= 1.minute
      :minute
    else
      :second
    end
  end
end

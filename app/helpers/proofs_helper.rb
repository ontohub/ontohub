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
end

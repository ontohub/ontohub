module ProofsHelper
  def form_url_chain
    chain = resource_chain
    chain << resource.proof_obligation if resource.theorem?
    chain << :proofs
  end

  def klass
    t("proofs.new.klass.#{resource.proof_obligation.class.to_s.underscore}")
  end
end

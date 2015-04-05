class ActionSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri

    def iri
      urls.action_iri_url(object, host: Settings.hostname)
    end
  end

  attributes :iri, :status, :eta

  def iri
    Reference.new(object).iri
  end

  def eta
    object.eta.to_i
  end
end

class ProofStatusSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri,
               :identifier,
               :name
    def iri
      url_for(object)
    end
  end

  attributes :iri,
             :identifier,
             :name,
             :description

  def iri
    Reference.new(object).iri
  end
end

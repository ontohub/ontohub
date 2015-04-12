class LogicMappingSerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri

    def iri
      urls.logic_mapping_url(object, host: Settings.hostname)
    end
  end

  attributes :iri
  attributes :standardization_status,
             :defined_by,
             :faithfulness,
             :exactness,
             :projection,
             :theoroidalness

  has_one :source_logic, serializer: LogicSerializer::Reference
  has_one :target_logic, serializer: LogicSerializer::Reference

  def iri
    Reference.new(object).iri
  end

  def source_logic
    object.source
  end

  def target_logic
    object.target
  end
end

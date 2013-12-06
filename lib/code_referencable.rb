module CodeReferencable
  extend ActiveSupport::Concern

  included do
    has_one :code_reference,
      as: :referencee,
      dependent: :delete
  end

end

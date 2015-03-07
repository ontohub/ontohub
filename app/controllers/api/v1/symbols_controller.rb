class Api::V1::SymbolsController < Api::V1::Base
  inherit_resources
  defaults resource_class: OntologyMember::Symbol

  actions :show
end

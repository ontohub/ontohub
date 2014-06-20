module Ontology::Import
  extend ActiveSupport::Concern

  def import_latest_version(user)
    import_version(versions.last, user)
  end

  def import_version(version, user)
    return if version.nil?
    evaluator = Hets::Evaluator.new(user, version.ontology, version: version)
    evaluator.import
  end

end

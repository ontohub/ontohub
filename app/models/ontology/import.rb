module Ontology::Import
  extend ActiveSupport::Concern

  def import_latest_version(user)
    import_version(versions.last, user)
  end

  def import_version(version, user, io)
    return if version.nil?
    evaluator = Hets::DG::Importer.new(user, version.ontology,
                                       version: version, io: io)
    evaluator.import
  end

  def import_proof(version, user, proof_attempt, io)
    evaluator = Hets::Prove::Importer.new(user,
                                          version.ontology,
                                          proof_attempt,
                                          version: version, io: io)
    evaluator.import
  end
end

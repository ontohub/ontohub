class DasherizeLocids < ActiveRecord::Migration
  def up
    ProofAttempt.find_each do |proof_attempt|
      locid = ProofAttempt.where(id: proof_attempt.id).pluck(:locid).first
      locid = locid.try(:sub, '//ProofAttempt-', '//proof-attempt-')
      proof_attempt.update_attributes!({locid: locid},
                                       without_protection: true)
    end
  end

  def down
    ProofAttempt.find_each do |proof_attempt|
      locid = ProofAttempt.where(id: proof_attempt.id).pluck(:locid).first
      locid = locid.try(:sub, '//proof-attempt-', '//ProofAttempt-')
      proof_attempt.update_attributes!({locid: locid},
                                       without_protection: true)
    end
  end
end

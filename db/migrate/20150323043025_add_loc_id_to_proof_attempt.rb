class AddLocIdToProofAttempt < MigrationWithData
  def up
    add_column :proof_attempts, :locid, :text

    ProofAttempt.find_each do |proof_attempt|
      pa_attrs = select_attributes(proof_attempt, :sentence_id, :number)

      theorem = Theorem.find(pa_attrs[:sentence_id])
      theorem_attrs = select_attributes(theorem, :locid)

      th_locid = theorem_attrs[:locid]
      locid = "#{th_locid}//proof-attempt-#{pa_attrs[:number]}"

      update_attributes!(proof_attempt, locid: locid)
    end
  end

  def down
    remove_column :proof_attempts, :locid, :text
  end
end

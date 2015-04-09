class MoveTacticScriptFromProofAttemptToSeparateModel < ActiveRecord::Migration
  def up
    ProofAttempt.find_each do |proof_attempt|
      tactic_script_json = ProofAttempt.where(id: proof_attempt).
        pluck(:tactic_script).first
      if tactic_script_json
        tactic_script_hash = JSON.parse(tactic_script_json)
        tactic_script = TacticScript.new
        tactic_script.
          update_attributes!({time_limit: tactic_script_hash['time_limit'].to_i,
                              proof_attempt_id: proof_attempt.id},
                             without_protection: true)
        tactic_script_hash['extra_options'].try(:each) do |option|
          extra_option = TacticScriptExtraOption.new
          extra_option.
            update_attributes!({option: option,
                                tactic_script_id: tactic_script.id},
                               without_protection: true)
        end
      end
    end
    remove_column :proof_attempts, :tactic_script
  end

  def down
    add_column :proof_attempts, :tactic_script, :text
    TacticScript.find_each do |tactic_script|
      extra_options = TacticScriptExtraOption.
        where(tactic_script_id: tactic_script).pluck(:option)
      time_limit =
        TacticScript.where(id: tactic_script).pluck(:time_limit).first
      proof_attempt_id =
        TacticScript.where(id: tactic_script).pluck(:proof_attempt_id).first
      proof_attempt = ProofAttempt.find(proof_attempt_id)
      tactic_script_json =
        {time_limit: time_limit, extra_options: extra_options}.to_json
      proof_attempt.update_attributes!({tactic_script: tactic_script_json},
                                       without_protection: true)
    end
  end
end

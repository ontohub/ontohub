class AddLocidToProofStatus < ActiveRecord::Migration
  def up
    add_column :proof_statuses, :locid, :text
    ProofStatus.find_each do |proof_status|
      proof_status.
        update_attributes!({locid: "/proof-statuses/#{proof_status.identifier}"},
                           without_protection: true)
    end
  end

  def down
    remove_column :proof_statuses, :locid
  end
end

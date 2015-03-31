class AddStateToProofAttemptsAndTheorems < ActiveRecord::Migration
  def up
    Theorem.find_each do |theorem|
      theorem.state = 'pending'
      theorem.save!
    end
  end
end

class AddProofStateToTheorem < ActiveRecord::Migration
  def change
    add_column :sentences, :proof_status, :string
  end
end

class CreateGoalStatuses < ActiveRecord::Migration
  def change
    create_table :goal_statuses do |t|
      t.string :status
      t.string :failure_reason

      t.references :proof_status, null: false

      t.timestamps
    end
  end
end

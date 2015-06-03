class AddDestroyJobIdToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :destroy_job_id, :string
    add_column :repositories, :destroy_job_at, :datetime
  end
end

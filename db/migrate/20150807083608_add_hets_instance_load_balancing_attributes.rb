class AddHetsInstanceLoadBalancingAttributes < ActiveRecord::Migration
  def change
    add_column :hets_instances, :state, :string
    add_column :hets_instances, :state_updated_at, :datetime
    add_column :hets_instances, :queue_size, :integer

    add_index :hets_instances, :state
  end
end

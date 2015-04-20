class AddDisplayNameToProver < MigrationWithData
  def change
    add_column :provers, :display_name, :string
    Prover.find_each do |prover|
      attrs = select_attributes(prover, :name, :display_name)
      unless attrs[:display_name]
        attrs[:display_name] = attrs[:name]
        update_attributes!(prover, attrs)
      end
    end
  end
end

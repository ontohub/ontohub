class ChangeProofStatusFromLocIdToSlugRouting < MigrationWithData
  def up
    remove_column :proof_statuses, :locid
    add_column :proof_statuses, :slug, :string
    ProofStatus.find_each do |proof_status|
      attrs = select_attributes(proof_status, :identifier,
                                search_column: :identifier)
      update_columns(proof_status, slug: attrs[:identifier])
    end
    change_column :proof_statuses, :slug, :string, null: false
    add_index :proof_statuses, :slug, unique: true
  end

  def down
    remove_column :proof_statuses, :slug
    add_column :proof_statuses, :locid, :text
    ProofStatus.find_each do |proof_status|
      attrs = select_attributes(proof_status, :identifier,
                                search_column: :identifier)
      locid = "/proof-statuses/#{attrs[:identifier]}"
      update_columns(proof_status, locid: locid)
    end
  end
end

class EnterNameForMappings < MigrationWithData
  def up
    Mapping.where(name: nil).select(:id).find_each do |mapping|
      iri = select_attributes(mapping, :iri)[:iri]
      linkid = iri.split('?').last
      if linkid != iri
        update_columns(mapping, name: "mapping-#{linkid}")
      else
        update_columns(mapping, name: "mapping-#{mapping.id}")
      end
    end
  end

  def down
    # Nothing to do because missing data was generated.
  end
end

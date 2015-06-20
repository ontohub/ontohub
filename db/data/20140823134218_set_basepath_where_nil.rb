class SetBasepathWhereNil < ActiveRecord::Migration
  def self.up
    OntologyVersion.where(basepath: nil).includes(:ontology).find_each do |ov|
      ov.basepath = ov.ontology.read_attribute(:basepath)
      ov.file_extension = ov.ontology.read_attribute(:file_extension)
      ov.save!
    end
  end

  def self.down
    # Nothing to do
    # This migration restores consistency. It should not be reversed.
  end
end

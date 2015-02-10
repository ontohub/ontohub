class FixOntologyVersionData < ActiveRecord::Migration
  def up
    DistributedOntology.find_each do |distributed_ontology|
      version_count = distributed_ontology.versions.count
      distributed_ontology.children.each do |child_ontology|
        child_ontology.versions.each do |child_version|
          parent_version = distributed_ontology.versions.
            where(number: version_count - child_version.number + 1).first
          child_version.commit_oid = parent_version.try(:commit_oid)
          child_version.basepath = parent_version.try(:basepath)
          child_version.pp_xml_name = parent_version.try(:pp_xml_name)
          child_version.xml_name = parent_version.try(:xml_name)
          child_version.file_extension = parent_version.try(:file_extension)
          child_version.parent = parent_version
          child_version.state = 'done'
          child_version.do_not_parse!
          child_version.save!
        end
      end
    end
  end

  def down
    DistributedOntology.find_each do |distributed_ontology|
      version_count = distributed_ontology.versions.count
      distributed_ontology.children.each do |child_ontology|
        child_ontology.versions.each do |child_version|
          parent_version = distributed_ontology.versions.
            where(number: version_count - child_version.number + 1).first
          child_version.commit_oid = nil
          child_version.basepath = nil
          child_version.pp_xml_name = nil
          child_version.xml_name = nil
          child_version.file_extension = nil
          child_version.parent = nil
          child_version.state = 'pending'
          child_version.do_not_parse!
          child_version.save!
        end
      end
    end
  end
end

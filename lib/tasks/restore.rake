namespace :restore do
  desc 'Restore missing paths in OntologyVersions'
  task :ontology_version_paths => :environment do
    def restore_last_kown_path(ontology_version)
      if prev_version = previous_version(ontology_version)
        if !prev_version.path.present?
          restore_last_kown_path(prev_version)
        end
        restore_last_kown_path_from_previous_version(ontology_version,
          prev_version)
      else
        restore_last_kown_path_from_ontology(ontology_version)
      end
    end

    def previous_version(ontology_version)
      ontology_version.ontology.versions.where(
        number: ontology_version.number - 1).first
    end

    def restore_last_kown_path_from_previous_version(version, prev_version)
      if version.path.present?
        restore_last_kown_path(prev_version)
      else
        version.basepath = prev_version.basepath
        version.file_extension = prev_version.file_extension
        version.save
      end
    end

    def restore_last_kown_path_from_ontology(version)
      if !version.path.present?
        ontology = version.ontology
        version.basepath = ontology.read_attribute(:basepath)
        version.file_extension = ontology.read_attribute(:file_extension)
        version.save
      end
    end

    OntologyVersion.where(basepath: nil).map(&:ontology).uniq.map do |o|
      restore_last_kown_path(o.versions.last)
    end
  end
end

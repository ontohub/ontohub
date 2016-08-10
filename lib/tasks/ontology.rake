namespace :ontology do
  desc 'Reanalyze old ontologies'
  task :reanalyze_all => :environment do
    Ontology.where(parent_id: nil, present: true).find_each do |ontology|
      if ontology.current_version.nil?
        commit_oid = ontology.repository.git.get_file!(ontology.path).oid
        ontology_version_options = OntologyVersionOptions.new(ontology.path,
          User.where(admin: true).first)

        OntologySaver.new(ontology.repository).
          save_ontology(commit_oid, ontology_version_options)
      else
        OntologyParsingMigrationWorker.
          perform_async([[ontology.current_version.id,
            {fast_parse: false, files_to_parse_afterwards: []}, 1]])
        Sidekiq::Client.push('queue' => 'hets-migration',
                     'class' => OntologyParsingWorker,
                     'args' => [[[ontology.current_version.id,
                                  {fast_parse: false,
                                   files_to_parse_afterwards: []}, 1]]])
      end
    end
  end
end
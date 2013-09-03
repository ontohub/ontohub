### Import ontologies.

# return files\' capital basename without extension
def basename_no_ext(filename)
  filename.split(".")[0]
end

Dir["#{Rails.root}/test/fixtures/ontologies/*/*.{casl,clf,clif,owl}"].each do |file|
  basename = File.basename(file)
  
  clazz = basename.ends_with?('.casl') ? DistributedOntology : SingleOntology
  
  o = clazz.new \
    iri:            "file://db/seeds/#{basename}",
    name:           basename_no_ext(basename).capitalize,
    description:    Faker::Lorem.paragraph,
    documentation:  Faker::Internet.url,
    acronym:        basename_no_ext(basename)[0..2].upcase

  v = o.versions.build raw_file: File.open(file)
  v.user       = @user
  v.created_at = rand(60).minutes.ago
  v.number     = 1
  
  o.save! 
  o.ontology_version = v;
  o.save!
end

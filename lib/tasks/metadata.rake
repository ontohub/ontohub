namespace :generate do
  desc 'Import the values for metadata'
  task :metadata => :environment do
    Settings.formality_levels.each do |t| FormalityLevel.create!(t.to_h) end
    Settings.license_models.each do |t| LicenseModel.create!(t.to_h) end
    Settings.ontology_types.each do |t| OntologyType.create!(t.to_h) end
    # hack: description field is too short
    Settings.tasks.each do |t| Task.create!(t.to_h.update({:description=>"too long"})) end
  end
end

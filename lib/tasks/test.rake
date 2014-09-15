namespace :test do

  # We want to purge our database our own way, without deleting everything
  Rake::Task['db:test:purge'].overwrite do
    Rails.env = 'test'
    Rake::Task['db:redis:clean'].invoke
    Rake::Task['db:migrate:clean'].invoke
  end

  desc 'Update all ontology fixtures'
  task :freshen_ontology_fixtures do
    args = [
      '-o xml',
      '--full-signatures',
      '-a none',
      '-v2',
      '-O test/fixtures/ontologies/xml',
      '+RTS -K1G -RTS',
      '--full-theories',
    ]
    hets = ->(file) { system("hets #{args.join(' ')} #{file}") }
    globbed_files = Dir.glob('test/fixtures/ontologies/**/*')
    files = globbed_files.select { |f| !f.end_with?('xml') && !File.directory?(f) }
    files.each do |file|
      puts "Calling hets for: #{file}"
      hets[file]
    end
  end

end

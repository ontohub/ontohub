namespace :test do

  # We want to purge our database our own way, without deleting everything
  Rake::Task['db:test:purge'].overwrite do
    Rails.env = 'test'
    Rake::Task['db:redis:clean'].invoke
    Rake::Task['db:migrate:clean'].invoke
  end

  def hets_path
    `which hets`.strip
  end

  def hets_out_file_for(ontology_file)
    basename = File.basename(ontology_file).sub(/\.[^.]+$/, '.xml')
    File.join('test/fixtures/ontologies/hets-out/', basename)
  end

  def perform_hets_on(file)
    args = [
      '-o xml',
      '--full-signatures',
      '-a none',
      '-v2',
      '-O test/fixtures/ontologies/hets-out',
      '+RTS -K1G -RTS',
      '--full-theories',
    ]
    system("hets #{args.join(' ')} #{file}")
  end

  def ontology_files
    globbed_files = Dir.glob('test/fixtures/ontologies/**/*')
    globbed_files.select do |file|
      !file.end_with?('xml') && !File.directory?(file)
    end
  end

  desc 'Update all ontology fixtures'
  task :freshen_ontology_fixtures do
    ontology_files.each do |file|
      puts "Calling hets for: #{file}"
      perform_hets_on(file)
    end
  end

end

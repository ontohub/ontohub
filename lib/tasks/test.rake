namespace :test do

  # We want to purge our database our own way, without deleting everything
  Rake::Task['db:test:purge'].overwrite do
    Rails.env = 'test'
    # Taken from https://github.com/rails/rails/blob/3-2-stable/activerecord/lib/active_record/railties/databases.rake#L512
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
    Rake::Task['db:redis:clean'].invoke
    Rake::Task['db:migrate:clean'].invoke
  end

  def hets_path
    `which hets`.strip
  end

  def hets_out_file_for(ontology_file)
    basename = File.basename(ontology_file).sub(/\.[^.]+$/, '.xml')
    File.join('spec/fixtures/ontologies/hets-out/', basename)
  end

  def on_outdated_files(files, &block)
    files.each do |file|
      hets_file = hets_out_file_for(file)
      out_of_date = !FileUtils.uptodate?(hets_file, Array(hets_path))
      block.call(file) if out_of_date
    end
  end

  def hets_args
    YAML.load(File.open('config/hets.yml'))['cmd_line_options']
  end

  def perform_hets_on(file)
    args = hets_args << '-O spec/fixtures/ontologies/hets-out'
    system("hets #{args.join(' ')} #{file}")
  end

  def ontology_files
    globbed_files = Dir.glob('spec/fixtures/ontologies/**/*')
    globbed_files.select do |file|
      !file.end_with?('xml') && !File.directory?(file)
    end
  end

  desc 'Update all ontology fixtures'
  task :freshen_ontology_fixtures do
    on_outdated_files(ontology_files) do |file|
      puts "Calling hets for: #{file}"
      perform_hets_on(file)
    end
  end

end

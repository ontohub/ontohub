namespace :test do

  # We want to purge our database our own way, without deleting everything
  Rake::Task['db:test:purge'].overwrite do
    Rails.env = 'test'
    # Taken from https://github.com/rails/rails/blob/3-2-stable/activerecord/lib/active_record/railties/databases.rake#L512
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
    Rake::Task['db:redis:clean'].invoke
    Rake::Task['db:migrate:clean'].invoke
  end

  def hets_config
    return @hets_config if @hets_config
    require File.expand_path('../../../lib/environment_light', __FILE__)
    old = AppConfig.setName('HetsSettings')
    AppConfig.load(false, 'config/hets.yml')
    AppConfig.setName(old)
    @hets_config = HetsSettings
  end

  def hets_path
    return @hets_path if @hets_path
    @hets_path = Array(hets_config['hets_path']).flatten
      .map { |path| File.expand_path path }
      .find { |path| File.exists?(path) }
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
    hets_config.cmd_line_options
  end

  def perform_hets_on(file)
    args = hets_args << '-O spec/fixtures/ontologies/hets-out'
    system(hets_path << " #{args.join(' ')} #{file}")
  end

  def ontology_files
    globbed_files = Dir.glob('spec/fixtures/ontologies/**/*')
    globbed_files.select do |file|
      !file.end_with?('proof.json') &&
      !file.end_with?('xml') &&
      !File.directory?(file)
    end
  end

  def prove_files
    globbed_files = Dir.glob('spec/fixtures/ontologies/prove/**/*')
    globbed_files.select do |file|
      !file.end_with?('.proof.json') && !File.directory?(file)
    end
  end

  def prove_with_hets(file)
    puts "Calling hets prover for #{file}"

    absolute_filepath = Rails.root.join(file)
    escaped_iri = Rack::Utils.escape_path("file://#{absolute_filepath}")
    command = %w(curl -s -X POST)
    command += ['-H', %('Content-Type: application/json')]
    command += ['-d', %('{"format": "json"}')]
    command << "http://localhost:8000/prove/#{escaped_iri}"
    command = command.join(' ')

    filename = File.basename(file).split('.')[0..-2].join('.')
    target_path = Rails.root.join('spec/fixtures/ontologies/hets-out/prove', filename)

    File.write("#{target_path}.proof.json", `#{command}`)
  end

  desc 'Update all ontology fixtures'
  task :freshen_ontology_fixtures do
    on_outdated_files(ontology_files) do |file|
      puts "Calling hets for: #{file}"
      perform_hets_on(file)
    end
  end

  desc 'Update all prove fixtures'
  task :freshen_prove_fixtures do
    hets_pid = fork { exec('hets -X') }
    # hets server needs some startup time
    sleep 1
    prove_files.each { |file| prove_with_hets(file) }
    puts 'Stopping hets server.'
    Process.kill('TERM', hets_pid)
  end

  desc 'Update all hets dependent fixtures'
  task :freshen_fixtures do
    Rake::Task['test:freshen_ontology_fixtures'].invoke
    Rake::Task['test:freshen_prove_fixtures'].invoke
  end
end

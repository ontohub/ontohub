namespace :test do
  require_relative '../../spec/support/fixtures_generation.rb'

  # We want to purge our database our own way, without deleting everything
  Rake::Task['db:test:purge'].overwrite do
    Rails.env = 'test'
    # Taken from https://github.com/rails/rails/blob/3-2-stable/activerecord/lib/active_record/railties/databases.rake#L512
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
    Rake::Task['db:redis:clean'].invoke
    Rake::Task['db:migrate:clean'].invoke
  end

  desc 'Update all fixtures'
  task :freshen_fixtures => :environment do
    [
      FixturesGeneration::OntologyGenerator,
      FixturesGeneration::ProversGenerator,
      FixturesGeneration::ProofGenerator,
      FixturesGeneration::ProverOutputGenerator
    ].map(&:new).
      select { |g| g.outdated_cassettes.any? }.
      each(&:call)
  end

  desc 'Update all ontology fixtures'
  task :freshen_ontology_fixtures do
    FixturesGeneration::OntologyGenerator.new.call
  end

  desc 'Update all provers fixtures'
  task :freshen_provers_fixtures do
    FixturesGeneration::ProversGenerator.new.call
  end

  desc 'Update all proof fixtures'
  task :freshen_proof_fixtures do
    FixturesGeneration::ProofGenerator.new.call
  end

  desc 'Update all prover output fixtures'
  task :freshen_prover_output_fixtures do
    FixturesGeneration::ProverOutputGenerator.new.call
  end

  desc 'Enable coverage report (only useful as prerequisite of other tasks)'
  task :enable_coverage do
    ENV['COVERAGE'] = 'true'
  end

  def port_open?(ip, port, seconds=1)
    require 'socket'
    require 'timeout'
    Timeout::timeout(seconds) do
      begin
        TCPSocket.new(ip, port).close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        false
      end
    end
  rescue Timeout::Error
    false
  end

  desc 'abort execution if elasticsearch is not running'
  task :abort_if_elasticsearch_is_not_running do
    elasticsearch_port = ENV['ELASTIC_TEST_PORT']
    elasticsearch_port = '9250' unless elasticsearch_port.present?
    unless port_open?('127.0.0.1', elasticsearch_port)
      $stderr.puts 'Elasticsearch is not running. Please start it before running the tests.'
      $stderr.puts 'Aborting tests.'
      exit 1
    end
  end
end

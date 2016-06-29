require_relative 'base_generator.rb'

module FixturesGeneration
  class PipelineGenerator < BaseGenerator
    RAILS_SERVER_TEST_FQDN = 'localhost'
    RAILS_SERVER_TEST_PORT = 3001
    RAILS_SERVER_TEST_PID = Rails.root.join('tmp', 'pids',
                                            'rails-server-test.pid')
    RAILS_SERVER_HOSTNAME = "#{RAILS_SERVER_TEST_FQDN}:#{RAILS_SERVER_TEST_PORT}"

    attr_reader :file, :subdir

    def initialize(file = nil, subdir = nil)
      super()
      @file = file
      @subdir = subdir
    end

    def call
      # We don't want to call this before the tests.
    end

    def with_cassette(cassette = nil, matcher = nil, &block)
      cassette ||= cassette_path_in_fixtures(file)
      vcr_options = {}
      vcr_options[:match_requests_on] = [:method, matcher] if matcher
      with_vcr(cassette, vcr_options) do
        ActiveRecord::Base.transaction do
          block.call
        end
      end
    rescue Hets::Errors::HetsError
      vcr_options[:record] = :all
      with_vcr(cassette, vcr_options) do
        with_running_hets do
          with_running_rails_server_test do
            block.call
          end
        end
      end
    end

    protected

    def with_vcr(cassette, vcr_options, &block)
      notice_localhost_while do
        VCR.use_cassette(cassette, vcr_options) do
          block.call
        end
      end
    end

    def notice_localhost_while(&block)
      VCR.configure { |c| c.ignore_localhost = false }
      result = block.call
      VCR.configure { |c| c.ignore_localhost = true }
      result
    end

    def files
      [file]
    end

    def with_running_rails_server_test(&block)
      port = RAILS_SERVER_TEST_PORT
      pid = RAILS_SERVER_TEST_PID
      with_running('rails server',
                   "bundle exec rails s -p #{port} -P #{pid} -e test",
                   port, 15, &block)
    end
  end
end

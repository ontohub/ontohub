module Hets
  class ActionCaller < Caller
    attr_accessor :hets_options, :repository

    def initialize(hets_instance, hets_options, repository)
      self.hets_options = hets_options
      self.repository = repository
      msg = "<#{hets_instance}> not up."
      raise Hets::InactiveInstanceError, msg unless hets_instance.try(:up?)
      super(hets_instance)
    end

    def build_query_string
      hets_options.options.merge('hets-libdirs' => libdirs)
    end

    def libdirs
      dir = "#{Hostname.url_authority}/#{repository.path}"
      dir = Rack::Utils.escape_path(dir)
    end

    def handle_possible_hets_error(error)
      HetsErrorProcess.new(error).handle
    rescue Hets::NotAHetsError
      raise error
    end
  end
end

module Hets
  class ActionCaller < Caller
    attr_accessor :hets_options

    def initialize(hets_instance, hets_options)
      self.hets_options = hets_options
      msg = "<#{hets_instance}> not up."
      raise Hets::InactiveInstanceError, msg unless hets_instance.try(:up?)
      super(hets_instance)
    end

    def build_query_string
      hets_options.options
    end

    def handle_possible_hets_error(error)
      HetsErrorProcess.new(error).handle
    rescue Hets::NotAHetsError
      raise error
    end
  end
end

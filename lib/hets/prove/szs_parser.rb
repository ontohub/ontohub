module Hets
  module Prove
    class SZSParser
      attr_reader :prover, :output

      def initialize(prover, output)
        @prover = prover
        @output = output
      end

      def call
        prover_specific_parser = :"parse_status_#{prover.downcase}"
        send(prover_specific_parser)
      rescue NameError
        generic_parse_status
      end

      private

      def generic_parse_status
        regex_parse_status(/SZS status (\w+)/)
      end

      def regex_parse_status(regex)
        match = output.match(regex)
        match[1] if match
      end
    end
  end
end

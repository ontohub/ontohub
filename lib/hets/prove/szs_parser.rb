module Hets
  module Prove
    class SZSParser
      attr_reader :prover, :output

      def initialize(prover, output)
        @prover = prover
        @output = output
      end

      def call
        prover_specific_parser =
          :"parse_status_#{prover.parameterize.gsub('-', '_')}"
        send(prover_specific_parser)
      rescue NameError
        generic_parse_status
      end

      private

      def generic_parse_status
        regex_parse_status(/SZS status (\w+)/)
      end

      def parse_status_darwin
        regex_parse_status(/\n\nSZS status (\w+) for/)
      end

      def parse_status_darwin_non_fd
        parse_status_darwin
      end

      def parse_status_eprover
        regex_parse_status(/\n# SZS status (\w+)/)
      end

      def regex_parse_status(regex)
        match = output.match(regex)
        match[1] if match
      end
    end
  end
end

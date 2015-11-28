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
        status = regex_parse_status(/\n\nSZS status (\w+)/)
        if status == 'Timeout'
          'ResourceOut'
        else
          status
        end
      end

      def parse_status_darwin_non_fd
        parse_status_darwin
      end

      def parse_status_eprover
        regex_parse_status(/\n# SZS status (\w+)/)
      end

      def parse_status_spass
        if match = generic_parse_status
          match
        elsif output.match(/^SPASS beiseite: Ran out of time.$/)
          'ResourceOut'
        end
      end

      def regex_parse_status(regex)
        match = output.match(regex)
        match[1] if match
      end
    end
  end
end

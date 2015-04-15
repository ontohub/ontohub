require 'spec_helper'

describe Hets::Prove::SZSParser do
  %w(Theorem CounterSatisfiable).each do |szs_status|
    %w(MathServeBroker
       SPASS
       Vampire).each do |prover|
      context "#{prover} on #{szs_status}" do
        let(:output) { File.read(prover_output_fixture(szs_status, prover)) }

        it "returns nil" do
          expect(Hets::Prove::SZSParser.new(prover, output).call).to be(nil)
        end
      end
    end

    %w(darwin
       darwin-non-fd
       eprover).each do |prover|
      context "#{prover} on #{szs_status}" do
        let(:output) { File.read(prover_output_fixture(szs_status, prover)) }

        it "returns status '#{szs_status}'" do
          expect(Hets::Prove::SZSParser.new(prover, output).call).
            to eq(szs_status)
        end
      end
    end
  end
end

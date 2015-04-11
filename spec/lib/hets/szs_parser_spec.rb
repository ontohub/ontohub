require 'spec_helper'

describe Hets::Prove::SZSParser do
  let(:fixtures_dir) do
    Rails.root.join('spec', 'fixtures', 'prover_outputs')
  end

  %w(Theorem CounterSatisfiable).each do |szs_status|
    %w(MathServeBroker
       SPASS
       Vampire).each do |prover|
      context "#{prover} on #{szs_status}" do
        let(:output) { File.read(fixtures_dir.join(szs_status, prover)) }

        it "returns nil" do
          expect(Hets::Prove::SZSParser.new(prover, output).call).to be(nil)
        end
      end
    end

    %w(darwin
       darwin-non-fd
       eprover).each do |prover|
      context "#{prover} on #{szs_status}" do
        let(:output) { File.read(fixtures_dir.join(szs_status, prover)) }

        it "returns status '#{szs_status}'" do
          expect(Hets::Prove::SZSParser.new(prover, output).call).
            to eq(szs_status)
        end
      end
    end
  end
end

require 'spec_helper'

describe SineAxiomSelection do
  let(:sine_axiom_selection) { create :sine_axiom_selection }

  context "respond to the parent's methods" do
    %i(finished lock_key mark_as_finished! proof_attempt_configurations
      axioms).each do |method|
      it method do
        expect(sine_axiom_selection).to respond_to(method)
      end
    end
  end

  context 'validations' do
    it 'is valid' do
      expect(sine_axiom_selection).to be_valid
    end

    context 'depth_limit' do
      context '10' do
        before { sine_axiom_selection.depth_limit = 10 }
        it 'is valid' do
          expect(sine_axiom_selection).to be_valid
        end
      end

      context 'less than -1' do
        before { sine_axiom_selection.depth_limit = -2 }
        it 'is invalid' do
          expect(sine_axiom_selection).to be_invalid
        end
      end

      context 'float' do
        before { sine_axiom_selection.depth_limit = 1.2 }
        it 'is invalid' do
          expect(sine_axiom_selection).to be_invalid
        end
      end

      context 'nil' do
        before { sine_axiom_selection.depth_limit = nil }
        it 'is invalid' do
          expect(sine_axiom_selection).to be_invalid
        end
      end
    end

    context 'commonness_threshold' do
      context 'less than 0' do
        before { sine_axiom_selection.commonness_threshold = -1 }
        it 'is invalid' do
          expect(sine_axiom_selection).to be_invalid
        end
      end

      context 'float' do
        before { sine_axiom_selection.commonness_threshold = 1.2 }
        it 'is invalid' do
          expect(sine_axiom_selection).to be_invalid
        end
      end

      context 'nil' do
        before { sine_axiom_selection.commonness_threshold = nil }
        it 'is invalid' do
          expect(sine_axiom_selection).to be_invalid
        end
      end
    end

    context 'tolerance' do
      context 'less than 1' do
        before { sine_axiom_selection.tolerance = 0 }
        it 'is invalid' do
          expect(sine_axiom_selection).to be_invalid
        end
      end

      context 'float' do
        before { sine_axiom_selection.tolerance = 1.5 }
        it 'is valid' do
          expect(sine_axiom_selection).to be_valid
        end
      end

      context 'nil' do
        before { sine_axiom_selection.tolerance = nil }
        it 'is invalid' do
          expect(sine_axiom_selection).to be_invalid
        end
      end
    end
  end
end

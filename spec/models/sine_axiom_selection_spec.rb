require 'spec_helper'

describe SineAxiomSelection do
  context "respond to the parent's methods" do
    let(:sine_axiom_selection) { create :sine_axiom_selection }
    subject { sine_axiom_selection }
    %i(goal ontology finished lock_key mark_as_finished!
      proof_attempt_configurations axioms).each do |method|
      it method do
        expect(subject).to respond_to(method)
      end
    end
  end

  context 'validations' do
    let(:sine_axiom_selection) { create :sine_axiom_selection }
    subject { sine_axiom_selection }

    it 'is valid' do
      expect(subject).to be_valid
    end

    context 'depth_limit' do
      context '10' do
        before { subject.depth_limit = 10 }
        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'less than -1' do
        before { subject.depth_limit = -2 }
        it 'is invalid' do
          expect(subject).to be_invalid
        end
      end

      context 'float' do
        before { subject.depth_limit = 1.2 }
        it 'is invalid' do
          expect(subject).to be_invalid
        end
      end

      context 'nil' do
        before { subject.depth_limit = nil }
        it 'is invalid' do
          expect(subject).to be_invalid
        end
      end
    end

    context 'commonness_threshold' do
      context 'less than 0' do
        before { subject.commonness_threshold = -1 }
        it 'is invalid' do
          expect(subject).to be_invalid
        end
      end

      context 'float' do
        before { subject.commonness_threshold = 1.2 }
        it 'is invalid' do
          expect(subject).to be_invalid
        end
      end

      context 'nil' do
        before { subject.commonness_threshold = nil }
        it 'is invalid' do
          expect(subject).to be_invalid
        end
      end
    end

    context 'tolerance' do
      context 'less than 1' do
        before { subject.tolerance = 0 }
        it 'is invalid' do
          expect(subject).to be_invalid
        end
      end

      context 'float' do
        before { subject.tolerance = 1.5 }
        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'nil' do
        before { subject.tolerance = nil }
        it 'is invalid' do
          expect(subject).to be_invalid
        end
      end
    end
  end

  context 'parameter influence' do
    setup_hets
    let(:repository) { create :repository }

    let(:ontology_fixture_file) { %w(prove/Subclass casl) }
    let(:ontology_filepath) { ontology_fixture_file.join('.') }

    before { stub_hets_for(ontology_filepath) }

    let(:parent_ontology_version) do
      version = version_for_file(repository,
                                 ontology_file(*ontology_fixture_file))
      version.parse
      version
    end

    let(:parent_ontology) { parent_ontology_version.ontology }

    let(:ontology) do
      parent_ontology.children.where(name: 'SubclassToleranceOnePointFive').first
    end
    let(:theorem) { ontology.theorems.first }

    let(:proof_attempt) { create :proof_attempt, theorem: theorem }
    let(:sine_axiom_selection) { create :sine_axiom_selection }
    subject { sine_axiom_selection }
    let!(:proof_attempt_configuration) do
      pac = proof_attempt.proof_attempt_configuration
      pac.axiom_selection = subject.axiom_selection
      subject.axiom_selection.proof_attempt_configurations = [pac]
      pac
    end

    context 'commonness threshold' do
      context '0' do
        before do
          subject.commonness_threshold = 0
          subject.call
        end

        it 'selects only transitivity' do
          expect(subject.axioms.map(&:name)).to match_array(['transitivity'])
        end
      end

      context '2' do
        before do
          subject.commonness_threshold = 2
          subject.call
        end

        it 'selects more axioms' do
          expect(subject.axioms.map(&:name)).
            to match_array(['guiness < beer', 'not stone < liquid',
                            'petrol < liquid', 'pilsner < beer',
                            'transitivity'])
        end
      end

      context '3' do
        before do
          subject.commonness_threshold = 3
          subject.call
        end

        it 'selects all axioms' do
          expect(subject.axioms.map(&:name)).
            to match_array(['beer < beverage', 'beverage < liquid',
                            'guiness < beer', 'not stone < liquid',
                            'petrol < liquid', 'pilsner < beer',
                            'transitivity'])
        end
      end
    end

    context 'commonness threshold with depth limit 0' do
      before { subject.depth_limit = 0 }

      context '0' do
        before do
          subject.commonness_threshold = 0
          subject.call
        end

        it 'selects nothing' do
          expect(subject.axioms.map(&:name)).to match_array([])
        end
      end

      context '2' do
        before do
          subject.commonness_threshold = 2
          subject.call
        end

        it 'selects more axioms' do
          expect(subject.axioms.map(&:name)).
            to match_array(['guiness < beer', 'not stone < liquid',
                            'petrol < liquid', 'pilsner < beer'])
        end
      end

      context '3' do
        before do
          subject.commonness_threshold = 3
          subject.call
        end

        it 'selects all axioms but transitivity' do
          expect(subject.axioms.map(&:name)).
            to match_array(['beer < beverage', 'beverage < liquid',
                            'guiness < beer', 'not stone < liquid',
                            'petrol < liquid', 'pilsner < beer'])
        end
      end
    end

    context 'depth limit' do
      context '0' do
        before do
          subject.depth_limit = 0
          subject.call
        end

        it 'selects nothing' do
          expect(subject.axioms.map(&:name)).to match_array([])
        end
      end

      context '1' do
        before do
          subject.depth_limit = 1
          subject.call
        end

        it 'selects transitivity' do
          expect(subject.axioms.map(&:name)).to match_array(['transitivity'])
        end
      end

      context '2' do
        before do
          subject.depth_limit = 2
          subject.call
        end

        it 'selects transitivity' do
          expect(subject.axioms.map(&:name)).to match_array(['transitivity'])
        end
      end
    end

    context 'depth limit with higher tolerance' do
      before { subject.tolerance = 1.5 }

      context '0' do
        before do
          subject.depth_limit = 0
          subject.call
        end

        it 'selects nothing' do
          expect(subject.axioms.map(&:name)).to match_array([])
        end
      end

      context '1' do
        before do
          subject.depth_limit = 1
          subject.call
        end

        it 'selects more axioms' do
          expect(subject.axioms.map(&:name)).
            to match_array(['beer < beverage', 'beverage < liquid',
                            'transitivity'])
        end
      end

      context '2' do
        before do
          subject.depth_limit = 2
          subject.call
        end

        it 'selects the same axioms as with 1' do
          expect(subject.axioms.map(&:name)).
            to match_array(['beer < beverage', 'beverage < liquid',
                            'transitivity'])
        end
      end
    end

    context 'tolerance' do
      context '1' do
        before do
          subject.tolerance = 1
          subject.call
        end

        it 'selects only transitivity' do
          expect(subject.axioms.map(&:name)).to match_array(['transitivity'])
        end
      end

      context '1.5' do
        before do
          subject.tolerance = 1.5
          subject.call
        end

        it 'selects more axioms' do
          expect(subject.axioms.map(&:name)).
            to match_array(['beer < beverage', 'beverage < liquid',
                            'transitivity'])
        end
      end

      context '3' do
        before do
          subject.tolerance = 3
          subject.call
        end

        it 'selects all axioms' do
          expect(subject.axioms.map(&:name)).
            to match_array(['beer < beverage', 'beverage < liquid',
                            'guiness < beer', 'not stone < liquid',
                            'petrol < liquid', 'pilsner < beer',
                            'transitivity'])
        end
      end
    end
  end
end

require 'spec_helper'

describe 'Ontology::Distributed' do
  let(:single) { FactoryGirl.create(:single_ontology) }
  let(:hetero_distributed) { FactoryGirl.create(:heterogeneous_ontology) }
  let(:homogeneous_distributed) { FactoryGirl.create(:homogeneous_ontology) }

  context 'heterogeneity' do
    it 'always be false if ontology is not distributed' do
      expect(single.heterogeneous?).to be(false)
    end

    context 'only be true if not all children of '\
      'distributed ontology are of same logic' do
      it 'heterogeneous registers as heterogeneous' do
        expect(hetero_distributed.heterogeneous?).to be(true)
      end
      it 'homogeneous registers as not heterogeneous' do
        expect(homogeneous_distributed.heterogeneous?).to be(false)
      end
    end

    context 'only be true if not all children of '\
      'distributed ontology are of same logic' do
      it 'heterogeneous registers as heterogeneous' do
        expect(hetero_distributed.heterogeneous?).to be(true)
      end
      it 'homogeneous registers as not heterogeneous' do
        expect(homogeneous_distributed.heterogeneous?).to be(false)
      end
    end

    context 'collections: homogeneous are distributed' do
      Ontology.homogeneous.map do |ontology|
        it "#{ontology} is homogeneous" do
          expect(ontology.homogeneous?).to be(true)
        end
        it "#{ontology} is distributed" do
          expect(ontology.distributed?).to be(true)
        end
      end

      context 'can be filtered according to a specific logic' do
        let(:ontology) { FactoryGirl.create(:heterogeneous_ontology) }
        let(:logic) { ontology.children.first.logic }
        let!(:ontologies) { Ontology.also_distributed_in(logic) }

        context 'retrieve only distributed ontologies '\
          'whose children belong to logic' do
          it 'one_uses' do
            ontologies.each do |ontology|
              expect(ontology.children.any? { |child| child.logic == logic }).
                to be(true)
            end
          end

          it "one doesn't use" do
            ontologies.each do |ontology|
              expect(ontology.children.any? { |child| child.logic != logic }).
                to be(true)
            end
          end
        end

        it 'retrieve the right number of ontologies' do
          expect(ontologies.size).to eq(1)
        end

        it 'include the right distributed ontology(/ies)' do
          expect(ontologies).to include(ontology)
        end
      end
    end
  end

  context 'homogeneity' do
    it 'always be true if ontology is not distributed' do
      expect(single.homogeneous?).to be(true)
    end

    context 'only be true if all children of '\
      'distributed ontology are of same logic' do
      it 'homogeneous registers as homogeneous' do
        expect(homogeneous_distributed.homogeneous?).to be(true)
      end
      it 'heterogeneous registers as not homogeneous' do
        expect(hetero_distributed.homogeneous?).to be(false)
      end
    end

    context 'collections' do
      before do
        FactoryGirl.create_list(:heterogeneous_ontology, 10)
        FactoryGirl.create_list(:homogeneous_ontology, 10)
      end

      context 'return only distributed homogeneous ontologies' do
        Ontology.homogeneous.map do |ontology|
          it "#{ontology} is homogeneous" do
            expect(ontology.homogeneous?).to be(true)
          end
          it "#{ontology} is distributed" do
            expect(ontology.distributed?).to be(true)
          end
        end
      end

      context 'can be filtered according to a specific logic' do
        let(:ontology) { FactoryGirl.create(:homogeneous_ontology) }
        let(:logic) { ontology.children.first.logic }
        let(:ontologies) { Ontology.distributed_in(logic) }

        it 'retrieve only distributed ontologies '\
          'which children belong to logic' do
          ontologies.each do |ontology|
            ontology.children.each do |child_ontology|
              expect(child_ontology.logic).to eq(logic)
            end
          end
        end

        it 'retrieve the right number of ontologies' do
          expect(ontologies.size).to eq(1)
        end

        it 'include the right distributed ontology(/ies)' do
          expect(ontologies).to include(ontology)
        end
      end
    end
  end
end

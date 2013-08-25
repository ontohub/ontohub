require 'test_helper'

class Ontology::DistributedTest < ActiveSupport::TestCase

  setup do
    @single = FactoryGirl.create(:single_ontology)
    @hetero_distributed = FactoryGirl.create(:heterogeneous_ontology)
    @homogeneous_distributed= FactoryGirl.create(:homogeneous_ontology)
  end

  context "heterogeneity" do

    should 'always be false if ontology is not distributed' do
      assert !@single.heterogeneous?
    end

    should 'only be true if not all children of distributed ontology are of same logic' do
      assert @hetero_distributed.heterogeneous?,
        "heterogeneous registers as not heterogeneous"
      assert !@homogeneous_distributed.heterogeneous?,
        "homogeneous registers as heterogeneous"
    end

    context "collections" do

      should "return only distributed homogeneous ontologies" do
        Ontology.homogeneous.map do |ontology|
          assert ontology.homogeneous?
          assert ontology.distributed?
        end
      end

      context "can be filtered according to a specific logic" do
        setup do
          @ontology = FactoryGirl.create(:heterogeneous_ontology)
          @logic = @ontology.children.first.logic
          @ontologies = Ontology.also_distributed_in(@logic)
        end

        should "retrieve only distributed ontologies which children belong to logic" do
          @ontologies.each do |ontology|
            one_uses = ontology.children.reduce(false) do |mem, ontology|
              ontology.logic == @logic ? true : mem
            end
            one_doesnt_use = ontology.children.reduce(false) do |mem, ontology|
              ontology.logic != @logic ? true : mem
            end

            assert one_uses
            assert one_doesnt_use
          end
        end

        should "retrieve the right number of ontologies" do
          assert_equal 1, @ontologies.size
        end

        should "include the right distributed ontology(/ies)" do
          assert @ontologies.include?(@ontology)
        end

      end

    end

  end

  context "homogeneity" do

    should 'always be true if ontology is not distributed' do
      assert @single.homogeneous?
    end

    should 'only be true if all children of distributed ontology are of same logic' do
      assert @homogeneous_distributed.homogeneous?,
        "homogeneous registers as not homogeneous"
      assert !@hetero_distributed.homogeneous?,
        "heterogeneous registers as homogeneous"
    end

    context "collections" do

      setup do
        FactoryGirl.create_list(:heterogeneous_ontology, 10)
        FactoryGirl.create_list(:homogeneous_ontology, 10)
      end

      should "return only distributed homogeneous ontologies" do
        Ontology.homogeneous.map do |ontology|
          assert ontology.homogeneous?
          assert ontology.distributed?
        end
      end

      context "can be filtered according to a specific logic" do
        setup do
          @ontology = FactoryGirl.create(:homogeneous_ontology)
          @logic = @ontology.children.first.logic
          @ontologies = Ontology.distributed_in(@logic)
        end

        should "retrieve only distributed ontologies which children belong to logic" do
          @ontologies.each do |ontology|
            ontology.children.each do |child_ontology|
              assert_equal @logic, child_ontology.logic
            end
          end
        end

        should "retrieve the right number of ontologies" do
          assert_equal 1, @ontologies.size
        end

        should "include the right distributed ontology(/ies)" do
          assert @ontologies.include?(@ontology)
        end

      end

    end

  end

end

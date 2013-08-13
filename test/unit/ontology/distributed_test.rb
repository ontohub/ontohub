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

  end

end

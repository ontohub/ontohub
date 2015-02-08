FactoryGirl.define do
  factory :theorem do |theorem|
    name { generate :sentence_name }
    text { Faker::Lorem.sentence }
    proof_status { create :proof_status_open }

    theorem.after(:build) do |theorem|
      parent_onto = create :distributed_ontology, :with_versioned_children
      theorem.ontology = parent_onto.children.first
    end
  end
end

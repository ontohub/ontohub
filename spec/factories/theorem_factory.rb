FactoryGirl.define do
  factory :theorem do |theorem|
    name { generate :sentence_name }
    text { Faker::Lorem.sentence }
    proof_status { create :proof_status_open }
    state { 'not_started_yet' }

    theorem.after(:build) do |theorem|
      if !theorem.ontology
        parent_onto = create :distributed_ontology, :with_versioned_children
        theorem.ontology = parent_onto.children.first
      end

    end
    theorem.after(:create) do |theorem|
      LocId.where(
                    locid: "#{theorem.ontology.locid}//#{theorem.name}",
                  ).first_or_create!(
                  assorted_object_id: theorem.id,
                  assorted_object_type: theorem.class.to_s,
                  )
    end
  end
end

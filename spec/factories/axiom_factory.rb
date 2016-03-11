FactoryGirl.define do
  factory :axiom do
    association :ontology, factory: :single_ontology
    name { FactoryGirl.generate :sentence_name }
    text { Faker::Lorem.sentence }

    after(:build) do |axiom|
      LocId.create(
                    locid: "#{axiom.ontology.locid}//#{axiom.name}",
                    assorted_object: axiom
                  )
    end
  end
end

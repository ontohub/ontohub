
FactoryGirl.define do

  factory :oops_request do
    association :ontology_version

    factory :oops_request_with_responses do
      after :build do |req|
        req.responses.build FactoryGirl.attributes_for(:oops_response)
      end
    end

  end

  factory :oops_response do
    element_type "Pitfall"
    sequence(:code) {|n| "P#{n}" }
    sequence(:name) {|n| "Some name #{n}" }
    description { Faker::Lorem.sentence }
  end

end

FactoryGirl.define do
  factory :logic_mapping do
    association :user
    association :source, factory: :logic
    association :target, factory: :logic
    iri { FactoryGirl.generate :iri }
    standardization_status { 'Unofficial' }
    faithfulness { 'not_faithful' }
    exactness { 'not_exact' }
    theoroidalness { 'unknown' }
    projection { false }
  end
end

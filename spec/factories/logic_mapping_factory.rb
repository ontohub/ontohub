FactoryGirl.define do
  factory :logic_mapping do
    association :user
    association :source, factory: :logic
    association :target, factory: :logic
    iri { FactoryGirl.generate :iri }
  end
end

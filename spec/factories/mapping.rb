FactoryGirl.define do

  factory :logic_mapping do
    association :user
    iri { FactoryGirl.generate :iri }
  end

  factory :language_mapping do
    association :user
    iri { FactoryGirl.generate :iri }
  end
end

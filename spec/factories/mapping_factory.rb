FactoryGirl.define do
  factory :mapping do
    iri { FactoryGirl.generate :iri }

    factory :import_mapping do
      kind 'import'
    end
  end

  factory :logic_mapping do
    association :user
    iri { FactoryGirl.generate :iri }
  end

  factory :language_mapping do
    association :user
    iri { FactoryGirl.generate :iri }
  end
end

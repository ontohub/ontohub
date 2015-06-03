FactoryGirl.define do
  factory :language do
    name { FactoryGirl.generate :name }
    iri { FactoryGirl.generate :iri }
  end
end

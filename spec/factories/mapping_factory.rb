FactoryGirl.define do

  factory :mapping do
    iri { FactoryGirl.generate :iri }

    factory :import_mapping do
      kind 'import'
    end
  end

end

FactoryGirl.define do

  factory :link do
    iri { FactoryGirl.generate :iri }

    factory :import_link do
      kind 'import'
    end
  end

end

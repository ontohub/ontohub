FactoryGirl.define do
  sequence :symbol_text do |n|
    "http://host/ontology/#{n}"
  end

  sequence :symbol_kind do |n|
    "Kind#{n}"
  end

  sequence :symbol_owl2_text do |n|
    "Class <http://example.com/resource##{n}>"
  end

  sequence :symbol_owl2_name do |n|
    "<http://example.com/resource##{n}>"
  end

  factory :symbol, class: OntologyMember::Symbol do
    association :ontology
    text { FactoryGirl.generate :symbol_text }
    kind { FactoryGirl.generate :symbol_kind }
    name { FactoryGirl.generate :name }

    after(:create) do |symbol|
      LocId.where(
                    locid: "#{symbol.ontology.locid}//#{symbol.name}",
                  ).first_or_create!(
                  assorted_object_id: symbol.id,
                  assorted_object_type: symbol.class.to_s,
                  )
    end

    factory :symbol_owl2 do
      text { FactoryGirl.generate :symbol_owl2_text }
      name { FactoryGirl.generate :symbol_owl2_name }

      after(:create) do |symbol|
        LocId.where(
                      locid: "#{symbol.ontology.locid}//#{symbol.name}",
                    ).first_or_create!(
                    assorted_object_id: symbol.id,
                    assorted_object_type: symbol.class.to_s,
                    )
      end
    end

    factory :symbol_with_ontology_version do
      after(:create) do |symbol|
        version =
          FactoryGirl.build(:ontology_version, ontology: symbol.ontology)
        symbol.ontology.versions << version
        symbol.ontology.save
        LocId.where(
                      locid: "#{symbol.ontology.locid}//#{symbol.name}",
                    ).first_or_create!(
                    assorted_object_id: symbol,
                    assorted_object_type: symbol.class.to_s,
                    )
      end
    end
  end
end

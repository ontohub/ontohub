FactoryGirl.define do
  
  factory :logic_mapping do
    iri { FactoryGirl.generate :iri }
    
  end
  
  factory :language_mapping do
    iri { FactoryGirl.generate :iri }
    
  end
end

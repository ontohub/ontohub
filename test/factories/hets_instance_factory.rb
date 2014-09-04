FactoryGirl.define do

  sequence :uri do |n|
    "gopher://host/ontology/#{n}"
  end

  sequence :hets_instance_name do |n|
    "hets_instance-#{n}"
  end

  factory :hets_instance do
    name { FactoryGirl.generate :hets_instance_name }
    uri { FactoryGirl.generate :uri }

    factory :local_hets_instance do
      uri { 'http://localhost:8000' }
    end
  end

end

FactoryGirl.define do

  sequence :uri do |n|
    "gopher://host/ontology/#{n}"
  end

  sequence :hets_instance_name do |n|
    "hets_instance-#{n}"
  end

  factory :hets_instance, aliases: [:local_hets_instance] do
    name { FactoryGirl.generate :hets_instance_name }
    uri { 'http://localhost:8000' }
    state { 'free' }
    queue_size { 0 }
  end

end

FactoryGirl.define do

  sequence :url do |n|
    "http://host/project/#{n}"
  end

  factory :project do
    name        { Faker::Lorem.words(3).join(' ') }
    contact     { Faker::Lorem.words(3).join(' ') }
    description { Faker::Lorem.sentences(3).join(' ') }
    institution { Faker::Lorem.words(3).join(' ') }
    homepage    { FactoryGirl.generate :url }
  end

end

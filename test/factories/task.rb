FactoryGirl.define do

  factory :task do
    name        { Faker::Lorem.words(3).join(' ') }
    description { Faker::Lorem.sentences(3).join(' ') }
  end

end

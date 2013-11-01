FactoryGirl.define do
  factory :url_map do
    source { Faker::Lorem.words(3).join('_') }
    target { Faker::Lorem.words(3).join('_') }
  end
end

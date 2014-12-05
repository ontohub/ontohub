FactoryGirl.define do
  factory :access_token do
    token { SecureRandom.hex(20) }
    expiration { 1.hours.from_now }
    association :repository
  end
end

FactoryGirl.define do
  factory :access_token do
    token { SecureRandom.hex(AccessToken::LENGTH) }
    expiration { 1.hours.from_now }
    association :repository
  end
end

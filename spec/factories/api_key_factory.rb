FactoryGirl.define do
  factory :api_key do
    association :user

    factory :invalid_api_key do
      status { 'invalid' }
    end
  end
end

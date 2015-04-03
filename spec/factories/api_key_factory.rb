FactoryGirl.define do
  factory :api_key, aliases: %i(valid_api_key) do
    association :user
    state { 'valid' }

    trait :invalid do
      state { 'invalid' }
    end
  end
end

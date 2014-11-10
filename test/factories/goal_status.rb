FactoryGirl.define do
  factory :goal_status do
    status { 'open' }
    failure_reason { nil }

    association :proof_status
  end
end

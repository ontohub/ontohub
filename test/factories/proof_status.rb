FactoryGirl.define do
  factory :proof_status do |proof_status|
    sequence(:goal_name) { |n| "Goal #{n}" }
    used_prover { 'SPASS' }
    used_time { Time.now }

    proof_status.after(:build) do |proof_status|
      proof_status.goal_status = build :goal_status, proof_status: proof_status
    end
  end
end

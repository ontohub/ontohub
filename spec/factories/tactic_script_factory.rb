FactoryGirl.define do
  factory :tactic_script do
    time_limit { 1 }
    association :proof_attempt

    trait :with_extra_options do
      after(:build) do |tactic_script|
        extra_options = [1,2].map { build :tactic_script_extra_option }
        tactic_script.extra_options = extra_options
      end

      after(:create) do |tactic_script|
        tactic_script.extra_options.each(&:save!)
        tactic_script.save!
      end
    end
  end
end

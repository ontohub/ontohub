FactoryGirl.define do
  factory :tactic_script_extra_option do
    option { Faker::Lorem.word }
    association :tactic_script
  end
end

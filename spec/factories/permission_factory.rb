FactoryGirl.define do
  factory :permission do
    role { "owner" }
    association :subject, :factory => :user
    association :item, :factory => :repository
  end
end

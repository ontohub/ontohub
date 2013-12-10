FactoryGirl.define do
  factory :c_edge do
    parent_id {FactoryGirl.create(:category).id}
    child_id {FactoryGirl.create(:category).id}
  end
end
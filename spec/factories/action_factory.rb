FactoryGirl.define do
  factory(:action) do
    association :resource, factory: :ontology
    initial_eta { 5.minutes }
  end
end

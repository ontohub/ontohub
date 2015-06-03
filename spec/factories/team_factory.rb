FactoryGirl.define do
  factory :team do
    name  { Faker::Lorem.words(2).join(" ") }

    factory :team_with_user_and_permission do |team|
      team.after(:build) do |team|
        user = FactoryGirl.create(:user, teams: [team])
        permission = FactoryGirl.create(:permission,
                                        subject: team,
                                        role: 'editor')
        team.permissions << permission
      end
    end
  end

  factory :team_user do
    association :team
    association :user
  end
end

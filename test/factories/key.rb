
FactoryGirl.define do

  factory :key do
    association :user
    name 'my key'
    key 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFoY047dBuHiWYi67TgKG0oKinCH0cNgJZu3lGIiUXCK0oXqktFrxeJjJnF9VG0ZLp+7tLl+mvmunNfBDVG9b7E= test@example'
  end

end
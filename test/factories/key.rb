
FactoryGirl.define do

  factory :key do
    association :user
    name 'my key'
    key 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDbOTVgBk3Ludz6f2C3AShBsCwdooY4sX3NEeP+531+J1cf333tWYx8hyK78srdrnWkN5RihgJTJHgvmprYyZZBFA6+Fr9hxaRu7YHCDl0JozEhnGHNSL2U0J/FanRM2aOnmNZRpDZ603Qr3o27UiPU7f7nIog0LwsNIMBmlLlaoQ== valid_key'
    factory :invalid_key do
      key 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFoY047dBuHiWYi67TgKG0oKinCH0cNgJZu3lGIiUXCK0oXqktFrxeJjJnF9VG0ZLp+7tLl+mvmunNfBDVG9b7E= test@example'
    end
  end

end

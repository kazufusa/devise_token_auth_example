FactoryBot.define do
  factory :user do
    email { "example@example.com" }
    password { "passwprd" }
    confirmed_at { Time.now.utc }
  end
end

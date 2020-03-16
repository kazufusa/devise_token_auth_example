FactoryBot.define do
  factory :user do
    name         { Faker::Name.name }
    email        { Faker::Internet.email }
    password     { "password" }
    confirmed_at { 1.year.ago.utc }
  end
end

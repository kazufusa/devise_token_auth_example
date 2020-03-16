FactoryBot.define do
  factory :session_history do
    name  { Faker::Name.name }
    ip { Faker::Internet.ip_v4_address }
    is_failed { false }
    created_at { Time.now.utc }
  end
end

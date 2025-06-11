FactoryBot.define do
  factory :admin_notification do
    subject { "New Events This Week" }
    content { "Check out these amazing new events coming up!" }
    association :sent_by, factory: :user, admin: true
    event_ids { [] }
    user_ids { [] }
    sent_at { nil }

    trait :sent do
      sent_at { 1.hour.ago }
    end

    trait :with_events do
      after(:build) do |notification|
        events = create_list(:event, 2, :approved)
        notification.event_ids = events.map(&:id)
      end
    end

    trait :with_users do
      after(:build) do |notification|
        users = create_list(:user, 3)
        notification.user_ids = users.map(&:id)
      end
    end
  end
end 
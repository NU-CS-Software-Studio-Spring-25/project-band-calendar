FactoryBot.define do
  factory :event do
    sequence(:name) { |n| "Concert #{n}" }
    date { 1.week.from_now }
    association :venue
    association :submitted_by, factory: :user
    approved { false }

    trait :approved do
      approved { true }
    end

    trait :with_bands do
      after(:create) do |event|
        bands = create_list(:band, 2)
        bands.each_with_index do |band, index|
          create(:band_event, event: event, band: band, set_position: index + 1)
        end
      end
    end
  end
end 
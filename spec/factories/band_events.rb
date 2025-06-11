FactoryBot.define do
  factory :band_event do
    association :event
    association :band
    set_position { 1 }
    start_time { event.date + 2.hours }
    end_time { event.date + 3.hours }
    notes { "Opening act" }
  end
end 
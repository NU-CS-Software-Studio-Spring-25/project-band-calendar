FactoryBot.define do
  factory :band do
    sequence(:name) { |n| "Band #{n}" }
    photo_url { "https://example.com/band-photo.jpg" }
    bio { "An amazing indie rock band from Brooklyn." }
  end
end 
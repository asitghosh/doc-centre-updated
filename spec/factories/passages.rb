FactoryGirl.define do
  factory :passage do
    content { Faker::Lorem.paragraphs.join(" ") }
  end
end

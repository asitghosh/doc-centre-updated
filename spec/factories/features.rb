FactoryGirl.define do
  factory :feature do
    title { Faker::Lorem.words(1 + rand(6)).join(" ").titleize }
    summary { Faker::Lorem.paragraphs(2).join(" ") }
    content { Faker::Lorem.paragraphs(4).join(" ") }

    trait :published do
      pub_status "published"
    end

    trait :draft do
      pub_status "draft"
    end

    #after(:build) { |feature| feature.class.skip_callback(:create, :after, :update_release_pdf) }
  end
end

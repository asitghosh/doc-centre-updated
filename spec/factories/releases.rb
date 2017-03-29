FactoryGirl.define do
  factory :release do
    before(:create) do |r|
      r.stub(:generate_pdf) { true }
    end

    sequence(:title)
    summary { Faker::Lorem.paragraphs.join(" ") }
    marketplace_improvements { Faker::Lorem.paragraphs(4).join(" ") }
    manager_improvements { Faker::Lorem.paragraphs(2).join(" ") }
    devcenter_improvements { Faker::Lorem.paragraphs.join(" ") }
    api_improvements { Faker::Lorem.paragraphs.join(" ") }

    slug { "#{title}" }

    trait :published do
      pub_status "released"
    end

    trait :draft do
      pub_status "draft"
    end

    trait :past do
      release_date { 31.days.ago }
    end

    trait :future do
      release_date { 7.days.from_now}
    end

    trait :present do
      release_date { Date.today }
    end

    trait :empty do
      marketplace_improvements { "" }
      manager_improvements { "" }
      devcenter_improvements { "" }
      api_improvements { "" }
    end

    trait :partially_empty do
      marketplace_improvements { "" }
      manager_improvements { "" }
      devcenter_improvements { "I am not empty" }
      api_improvements { "" }
    end

    #after(:build) { |release| release.class.skip_callback(:create, :after, :generate_pdf) }
  end

  factory :release_with_features, :parent => :release do
    after(:create) { |r| 5.times { FactoryGirl.create(:feature, :release => r) } }
  end

  factory :very_old_release, :parent => :release do
    after(:create) do |r|
      r.update_column(:created_at, 2.months.ago)
      r.update_column(:updated_at, 2.months.ago)
    end
  end

end

FactoryGirl.define do
  factory :release_with_callbacks, class: Release do
    sequence(:title)
    summary { Faker::Lorem.paragraphs.join(" ") }
    marketplace_improvements { Faker::Lorem.paragraphs(4).join(" ") }
    manager_improvements { Faker::Lorem.paragraphs(2).join(" ") }
    devcenter_improvements { Faker::Lorem.paragraphs.join(" ") }
    api_improvements { Faker::Lorem.paragraphs.join(" ") }

    slug { "#{title}" }

    trait :published do
      pub_status "released"
    end

    trait :present do
      release_date { Date.today }
    end
  end
end

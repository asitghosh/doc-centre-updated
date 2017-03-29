# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :roadmap do
    title { Faker::Lorem.words(1 + rand(6)).join(" ").titleize }
    content { Faker::Lorem.paragraphs(2).join(" ") }
    redirect_to_first_child false
    pub_status "planned"

    trait :draft do
      pub_status "draft"
    end

    trait :quarter do
      is_a_quarter true
    end

    trait :planned do
      pub_status "planned"
    end

    trait :ongoing do
      pub_status "ongoing"
    end

    trait :in_progress do
      pub_status "in_progress"
    end

    trait :complete do
      pub_status "complete"
    end

    trait :redirect do
      redirect_to_first_child true
    end

    trait :with_parent_redirect do
      after(:build) do |p|
        p.parent = FactoryGirl.create(:roadmap, :redirect)
      end
    end

  end
end

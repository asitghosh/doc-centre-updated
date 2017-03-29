# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :support do
    title { Faker::Lorem.words(1 + rand(6)).join(" ").titleize }
    body { Faker::Lorem.paragraphs(2).join(" ") }
    redirect_to_first_child false
    pub_status "published"

    trait :draft do
      pub_status "draft"
    end

    trait :redirect do
      redirect_to_first_child true
    end

    trait :with_parent_redirect do
      after(:build) do |p|
        p.parent = FactoryGirl.create(:support, :redirect)
      end
    end

    # trait :with_passages do
    #   after(:create) { |p| 5.times { p.passages << FactoryGirl.create(:passage) } }
    # end

  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :api do
    title { Faker::Lorem.words(1 + rand(6)).join(" ").titleize }
    body { Faker::Lorem.paragraphs(2).join(" ") }
    redirect_to_first_child false
    pub_status "published"
    type "Api"
    
    trait :draft do
      pub_status "draft"
    end

    trait :redirect do
      redirect_to_first_child true
    end

    trait :with_children do
      after(:create) do |p|
        p.children << FactoryGirl.create(:api, :parent_id => p.id )
      end
    end

    factory :api_with_children do
      with_children
    end
  end

end

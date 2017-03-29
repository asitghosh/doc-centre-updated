# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :channel_partner do
    name "AppDirect"
    logo "http://placehold.it/200x100"
    subdomain { Faker::Lorem.characters(char_count = 10) }
    color "2395ff"
    able_to_see_releases true
    able_to_see_roadmaps true
    able_to_see_user_guides true
    able_to_see_faqs true
    able_to_see_supports true

    trait :multitenant do
        after(:create) do |cp|
            cp.open_id_urls.create({ :open_id_url => "https://www.example.com/openid/id" })
        end
    end

    after(:build) do |cp|
      cp.account_reps << FactoryGirl.create(:account_rep)
    end

    after(:create) do |cp|
        cp.open_id_urls.create({ :open_id_url => "https://www.appdirect.com/openid/id"})
    end
  end
end

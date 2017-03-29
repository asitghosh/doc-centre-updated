# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email Faker::Internet.email
    password Devise.friendly_token[0,20]
    name Faker::Name.name

    factory :superadmin do
      after(:create) do |user|
        user.add_role(:superadmin)
        user.add_role(:appdirect_employee)
      end
    end

    factory :appdirect_employee do
      after(:create) { |user| user.add_role(:appdirect_employee) }
    end

    factory :account_rep do
      after(:create) { |user| user.add_role(:account_rep) }
    end

    factory :channel_admin do
      after(:create) do |user|
        user.add_role(:channel_admin)
      end
    end
  end
end

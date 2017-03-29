FactoryGirl.define do
  factory :hotfix do
    content { Faker::Lorem.paragraphs(2).join(" ") }
    pub_status "published"
  end
end

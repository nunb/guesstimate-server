FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user #{n}" }
    sequence(:auth0_id) { |n| "auth0_id #{n}" }
    has_private_access false
    plan :personal_free
  end

  trait :small_plan do
    has_private_access true
    plan :personal_lite
  end

  trait :large_plan do
    has_private_access true
    plan :personal_premium
  end
end

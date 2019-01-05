FactoryBot.define do
  factory :review do
    user
    item
    sequence(:title) { |n| "Title #{n}" }
    sequence(:description) { |n| "Description #{n}" }
    sequence(:rating) { |n| n%5 + 1 }
    active { true }
  end
  factory :disabled_review do
    user
    item
    sequence(:title) { |n| "Title #{n}" }
    sequence(:description) { |n| "Description #{n}" }
    sequence(:rating) { |n| n%5 + 1 }
    active { false }
  end
end

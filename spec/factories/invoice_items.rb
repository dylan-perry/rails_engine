require 'faker'

FactoryBot.define do
  factory :invoice_item do
    quantity { Faker::Number.within(range: 1..10) } 
    unit_price { Faker::Number.number(digits: 5) } 
    association :item
    association :invoice
  end
end
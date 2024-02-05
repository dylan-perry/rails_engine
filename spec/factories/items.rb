FactoryBot.define do
    factory :item do
        name { Faker::Coffee.variety }
        description { Faker::Lorem.sentence }
        unit_price { Faker::Number.within(range: 1.00..100.00) }
    end
end
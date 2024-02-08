# spec/factories/invoices.rb

FactoryBot.define do
  factory :invoice do
    association :customer
    association :merchant
    status { [:shipped, :cancelled, :in_progress].sample }  
  end
end

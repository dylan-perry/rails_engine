class Item < ApplicationRecord
    validates :name, :description, :unit_price, presence: true
end
class Item < ApplicationRecord
    validates :name, :description, :unit_price, presence: true

    belongs_to :merchant
end

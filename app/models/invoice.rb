class Invoice < ApplicationRecord
  has_many :invoice_items
  has_many :items, through: :invoice_item
  belongs_to :customer
  belongs_to :merchant

  validates :status, presence: true

  enum status: {shipped: 0, cancelled: 1, in_progress: 2}
end
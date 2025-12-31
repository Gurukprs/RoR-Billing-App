class BillItem < ApplicationRecord
  belongs_to :bill, counter_cache: true
  belongs_to :product
  # validations
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  scope :with_product, -> { includes(:product) }
end

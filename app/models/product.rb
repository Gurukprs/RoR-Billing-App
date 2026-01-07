class Product < ApplicationRecord
  has_many :bill_items
  has_many :bills, through: :bill_items
  
  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :tax_percentage, numericality: { greater_than_or_equal_to: 0 }
end

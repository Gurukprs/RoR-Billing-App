class Bill < ApplicationRecord
  has_many :bill_items, dependent: :destroy
  has_many :products, through: :bill_items

  accepts_nested_attributes_for :bill_items, allow_destroy: true
# Validations
  validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :cash_paid, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :recent, -> { order(created_at: :desc) }

  def calculate_totals
    self.total_without_tax = bill_items.sum(:total_price)
    self.total_tax         = bill_items.sum(:tax_amount)
    self.net_total         = total_without_tax + total_tax
    self.rounded_total     = net_total.floor
    self.balance_payable   = cash_paid - rounded_total if cash_paid
  end

  def calculated_total_without_tax
    bill_items.sum(:total_price) || 0
  end

  def calculated_total_tax
    bill_items.sum(:tax_amount) || 0
  end

  def calculated_net_total
    calculated_total_without_tax + calculated_total_tax
  end

  def calculated_rounded_total
    calculated_net_total.floor
  end

  def calculated_balance_payable
    return nil unless cash_paid
    cash_paid - calculated_rounded_total
  end
end

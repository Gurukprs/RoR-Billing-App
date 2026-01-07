class BillsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :show]
  before_action :set_bill, only: [:show]
  def new
    @bill = Bill.new
    @bill.bill_items.build
    @products = Product.all
    @denominations = [500, 200, 100, 50, 20, 10]
  end

  def create
    @bill = Bill.new(bill_params)
    build_bill_items
    
    @products = Product.all
    @denominations = [500, 200, 100, 50, 20, 10]
    
    if @bill.bill_items.empty?
      flash.now[:alert] = "Please add at least one product"
      render :new and return
    end
    @bill.calculate_totals
    
    validate_denominations
    validate_cash_paid

    if @bill.errors.any?
      render :new and return
    end

    if @bill.save
      redirect_to @bill, notice: "Bill generated successfully"
    else
      render :new
    end
  end

  def show
    @bill_items = @bill.bill_items.includes(:product)
    @balance_denominations = @bill.balance_denominations
  end

  private
  def set_bill
    @bill = Bill.includes(bill_items: :product).find(params[:id])
  end
  
  def bill_params
    params.require(:bill).permit(
      :customer_email,
      :cash_paid,
      bill_items_attributes: [:product_id, :quantity, :_destroy]
    )
  end

  def build_bill_items
    @bill.bill_items.each do |item|
      product = Product.find_by(id: item.product_id)
      next unless product

      item.unit_price = product.price
      item.total_price = product.price * item.quantity
      item.tax_amount = (item.total_price * product.tax_percentage) / 100
    end
  end

  def denomination_params
    params.fetch(:denominations, {}).transform_values(&:to_i)
  end

  def validate_denominations
    total_from_denominations = 0

    denomination_params.each do |value, count|
      if count < 0
        @bill.errors.add(:base, "Denomination #{value} count cannot be negative")
      end

      total_from_denominations += value.to_i * count
    end

    if @bill.cash_paid.present? && total_from_denominations != @bill.cash_paid.to_f
      @bill.errors.add(
        :base,
        "Total of denominations (#{total_from_denominations}) must equal cash given by customer (#{@bill.cash_paid})"
      )
    end
  end

  def validate_cash_paid
  return if @bill.cash_paid.blank?

  if @bill.cash_paid < @bill.rounded_total
    @bill.errors.add(
      :cash_paid,
      "must be greater than or equal to bill amount (#{@bill.rounded_total})"
    )
  end
end


end



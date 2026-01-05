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
    
    if @bill.bill_items.empty?
      flash.now[:alert] = "Please add at least one product"
      render :new and return
    end
    @bill.calculate_totals

    if @bill.save
      redirect_to @bill, notice: "Bill generated successfully"
    else
      render :new
    end
  end

  def show
    @bill_items = @bill.bill_items.includes(:product)
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
end


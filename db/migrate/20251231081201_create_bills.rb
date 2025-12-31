class CreateBills < ActiveRecord::Migration[6.1]
  def change
    create_table :bills do |t|
      t.string :customer_email
      t.decimal :cash_paid
      t.decimal :total_without_tax
      t.decimal :total_tax
      t.decimal :net_total
      t.decimal :rounded_total
      t.decimal :balance_payable
      t.integer :bill_items_count, default: 0

      t.timestamps
    end
  end
end

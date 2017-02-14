class CreateErpPaymentsDebts < ActiveRecord::Migration[5.0]
  def change
    create_table :erp_payments_debts do |t|
      t.references :order, index: true, references: :erp_orders_orders
      t.datetime :deadline
      t.string :note
      t.boolean :archived, default: false
      t.references :creator, index: true, references: :erp_users

      t.timestamps
    end
  end
end

class CreateErpPaymentsPaymentRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :erp_payments_payment_records do |t|
      t.string :code
      t.string :payment_type
      t.decimal :amount
      t.datetime :payment_date
      t.text :description
      t.string :status
      t.boolean :archived, default: false
      t.references :order, index: true, references: :erp_orders_orders
      t.references :accountant, index: true, references: :erp_users
      t.references :contact, index: true, references: :erp_contacts_contacts
      t.references :creator, index: true, references: :erp_users

      t.timestamps
    end
  end
end

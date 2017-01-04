class CreateErpPaymentsPaymentMethods < ActiveRecord::Migration[5.0]
  def change
    create_table :erp_payments_payment_methods do |t|
      t.string :name
      t.string :type_method
      t.boolean :is_default
      t.boolean :archived, default: false
      t.references :creator, index: true, references: :erp_users

      t.timestamps
    end
  end
end

class CreateErpPaymentsPaymentTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_payments_payment_types do |t|
      t.string :name
      t.string :code
      t.boolean :is_payable
      t.boolean :is_receivable
      t.string :status

      t.timestamps
    end
  end
end

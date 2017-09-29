class CreateErpPaymentsPaymentTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_payments_payment_types do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
  end
end

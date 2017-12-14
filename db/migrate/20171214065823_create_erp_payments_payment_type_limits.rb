class CreateErpPaymentsPaymentTypeLimits < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_payments_payment_type_limits do |t|
      t.references :payment_type, index: true, references: :erp_payments_payment_types
      t.references :period, index: true, references: :erp_periods_periods
      t.decimal :amount, default: 0.0

      t.timestamps
    end
  end
end

class AddPaymentMethodToErpPaymentsPaymentRecords < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_payments_payment_records, :payment_method, :string
  end
end

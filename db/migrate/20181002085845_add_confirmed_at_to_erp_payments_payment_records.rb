class AddConfirmedAtToErpPaymentsPaymentRecords < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_payments_payment_records, :confirmed_at, :datetime
  end
end

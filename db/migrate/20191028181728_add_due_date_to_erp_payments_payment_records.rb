class AddDueDateToErpPaymentsPaymentRecords < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_payments_payment_records, :due_date, :datetime
  end
end

class AddHaveDueDateToErpPaymentsPaymentTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_payments_payment_types, :have_due_date, :boolean
  end
end

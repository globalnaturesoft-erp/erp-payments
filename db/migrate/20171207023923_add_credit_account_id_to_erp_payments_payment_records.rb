class AddCreditAccountIdToErpPaymentsPaymentRecords < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_payments_payment_records, :credit_account_id, :integer
  end
end

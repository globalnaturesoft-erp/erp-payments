class AddCacheSearchToErpPaymentsPaymentRecords < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_payments_payment_records, :cache_search, :string
  end
end

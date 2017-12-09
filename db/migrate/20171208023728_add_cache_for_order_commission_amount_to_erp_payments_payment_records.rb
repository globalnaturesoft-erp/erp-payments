class AddCacheForOrderCommissionAmountToErpPaymentsPaymentRecords < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_payments_payment_records, :cache_for_order_commission_amount, :decimal, default: 0.0
  end
end

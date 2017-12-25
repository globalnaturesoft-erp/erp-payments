class AddOriginDocToErpPaymentsPaymentRecords < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_payments_payment_records, :origin_doc, :string
  end
end

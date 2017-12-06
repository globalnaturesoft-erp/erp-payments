class AddStatusToErpPaymentsAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_payments_accounts, :status, :string
  end
end

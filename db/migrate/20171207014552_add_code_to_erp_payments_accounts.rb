class AddCodeToErpPaymentsAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_payments_accounts, :code, :string
  end
end

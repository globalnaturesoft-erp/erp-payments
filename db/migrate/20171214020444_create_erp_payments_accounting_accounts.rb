class CreateErpPaymentsAccountingAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_payments_accounting_accounts do |t|
      t.string :code
      t.string :name
      t.string :status
      t.references :creator, index: true, references: :erp_users

      t.timestamps
    end
  end
end

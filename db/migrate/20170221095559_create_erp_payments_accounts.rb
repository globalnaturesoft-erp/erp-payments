class CreateErpPaymentsAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :erp_payments_accounts do |t|
      t.string :name
      t.string :account_number
      t.string :owner
      t.boolean :archived, default: false
      t.references :creator, index: true, references: :erp_users

      t.timestamps
    end
  end
end

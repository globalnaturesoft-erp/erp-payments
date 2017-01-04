class CreateErpPaymentsPaymentTerms < ActiveRecord::Migration[5.0]
  def change
    create_table :erp_payments_payment_terms do |t|
      t.string :name
      t.integer :timeout, default: 0
      t.string :started_on
      t.boolean :is_default
      t.boolean :archived, default: false
      t.references :creator, index: true, references: :erp_users

      t.timestamps
    end
  end
end

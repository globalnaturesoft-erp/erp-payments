class AddInitDebtAmountToErpContactsContacts < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_contacts_contacts, :init_debt_amount, :decimal, default: 0.0
    add_column :erp_contacts_contacts, :init_debt_date, :datetime
  end
end

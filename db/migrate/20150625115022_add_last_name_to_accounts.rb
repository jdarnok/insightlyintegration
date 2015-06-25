class AddLastNameToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :last_name, :string
  end
end

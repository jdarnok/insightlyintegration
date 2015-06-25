class AddFirstNameToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :first_name, :string
  end
end

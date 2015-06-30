class AddBrickMortarToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :brick_mortar, :boolean
  end
end

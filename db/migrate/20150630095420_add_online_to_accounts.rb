class AddOnlineToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :online, :boolean
  end
end

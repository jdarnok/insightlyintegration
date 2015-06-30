class AddInsightlyContactIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :insightly_contact_id, :integer
  end
end

class AddOrganisationToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :organisation, :string
  end
end

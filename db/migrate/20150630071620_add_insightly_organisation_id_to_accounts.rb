class AddInsightlyOrganisationIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :insightly_organisation_id, :integer
  end
end

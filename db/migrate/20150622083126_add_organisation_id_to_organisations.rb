class AddOrganisationIdToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :organisation_id, :integer
  end
end

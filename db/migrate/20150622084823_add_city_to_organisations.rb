class AddCityToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :city, :string
  end
end

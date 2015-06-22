class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.string :domain
      t.string :website
      t.string :address
      t.string :country
      t.string :state
      t.string :postcode
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :organisations, :users
  end
end

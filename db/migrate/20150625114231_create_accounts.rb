class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :phone
      t.string :email
      t.string :website
      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.string :postcode
      t.string :country

      t.timestamps null: false
    end
  end
end

class AddPostcodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :postcode, :string
  end
end

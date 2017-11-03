class AddLocationToCoordinates < ActiveRecord::Migration[5.1]
  def change
    add_column :coordinates, :address, :string
    add_column :coordinates, :zipcode, :string
    add_column :coordinates, :city, :string
    add_column :coordinates, :state, :string
  end
end

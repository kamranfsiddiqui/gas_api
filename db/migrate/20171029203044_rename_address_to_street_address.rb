class RenameAddressToStreetAddress < ActiveRecord::Migration[5.1]
  def change
    rename_column :coordinates, :address, :street_address
  end
end

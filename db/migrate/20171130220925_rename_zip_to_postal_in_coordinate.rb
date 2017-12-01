class RenameZipToPostalInCoordinate < ActiveRecord::Migration[5.1]
  def change
    rename_column :coordinates, :zipcode, :postal_code
  end
end

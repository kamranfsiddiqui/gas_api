class ChangeZipTypelInCoordinate < ActiveRecord::Migration[5.1]
  def change
    change_column :coordinates, :zipcode, :string
  end
end

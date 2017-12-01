class ChangeZipToPostalInCoordinate < ActiveRecord::Migration[5.1]
  def change
    change_column :coordinates, :zipcode, :postal_code
  end
  def down
    change_column :coordinates, :zipcode, :string
  end
  def up
    change_column :coordinates, :zipcode, :postal_code
  end
end

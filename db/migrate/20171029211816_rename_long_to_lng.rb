class RenameLongToLng < ActiveRecord::Migration[5.1]
  def change
    rename_column :coordinates, :long, :lng
  end
end

class AddCoordinatesIdToGasStation < ActiveRecord::Migration[5.1]
  def change
    add_reference :gas_stations, :coordinates, index: true 
    add_foreign_key :gas_stations, :coordinates
  end
end

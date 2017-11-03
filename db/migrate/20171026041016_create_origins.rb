class CreateOrigins < ActiveRecord::Migration[5.1]
  def change
    create_table :origins do |t|
      t.string :street_address
      t.string :city
      t.string :state
      t.string :postal_code

      t.timestamps
    end
  end
end

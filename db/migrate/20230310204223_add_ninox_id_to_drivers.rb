class AddNinoxIdToDrivers < ActiveRecord::Migration[7.0]
  def change
    add_column :drivers, :ninox_id, :string
  end
end

class AddSamsaraIdIdToDrivers < ActiveRecord::Migration[7.0]
  def change
    add_column :drivers, :samsara_id, :string
  end
end

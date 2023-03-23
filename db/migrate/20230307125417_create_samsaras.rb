class CreateSamsaras < ActiveRecord::Migration[7.0]
  def change
    create_table :samsaras do |t|
      t.string :truck
      t.decimal :odo_miles
      t.date :date
      t.string :gps_location
      t.timestamps
    end
  end
end

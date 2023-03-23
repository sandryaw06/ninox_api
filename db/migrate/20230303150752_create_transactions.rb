class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.string :truck
      t.decimal :sub_total
      t.date :post_data
      t.date :event_data
      t.string :time_post_data
      t.string :time_event_data
      t.string :product_name
      t.string :product_qty
      t.decimal :product_cost
      t.string :loves_station
      t.string :odomiles
      t.string :gps_location

      t.timestamps
    end
  end
end

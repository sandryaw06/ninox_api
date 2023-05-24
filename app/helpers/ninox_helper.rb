module NinoxHelper

    def ninox_connection(url,params, headers)
        #this is DB Lightning -> vyuovmo86ovn
        ninox_url = "https://api.ninox.com/v1/teams/85Qr2bLduF54cjRuY/databases/g132f7q7golx/+#{url}"
        headers["Authorization"] = "Bearer c54f1a10-be9a-11ed-99d8-55c64db17004"
        conn = Faraday.new(
            url: ninox_url,
            params: params,
            headers: headers
          )
    end

    def ninox_connection_transaction_table
        ninox_url = "tables/ME/records"
        conn = ninox_connection({},{})
        response = conn.get(ninox_url)
        response = JSON.parse(response.body)
        response["data"]
    end
    
    def post_transaction_table(transactions)
        ninox_transactions = []
        transactions = JSON.parse(transactions.to_json)

        transactions.each do |t|
            if t["product_details"].include? "DEF" or t["product_details"].include? "Diesel"
                is_fuel = true
            end
                
            new_record = {"fields": {
                "truck_": t["truck"],
                "station_": t["station"],
                "eventDate_": t["event_data"],
                "postDate_": t["post_data"],
                "postHr_": t["postHr"],
                "eventHr_": t["eventHr"],
                "subTotal_": t["sub_total"],
                "total_ajustado_": t["adjustment_total"],
                "productDetails_": t["product_details"],
                "odoMiles_": t["odomiles"],
                "gps_": t["gps_location"],
                "is_fuel_": is_fuel ? is_fuel : false,
                "diesel_discount_": t["product_discount"],
                "diesel_adjustedPrice_": t["product_adjustment_price"],
                "diesel_productTotal_": t["product_total"],
                "diesel_qty_": t["product_diesel_qty"],
                "diesel_unit_price_": t["product_diesel_cost"],
                "def_discount_": t["def_discount"],
                "def_unit_price_": t["def_cost"],
                "def_qty_": t["def_qty"],
                "def_adjustedPrice_": t["def_adjustment_price"],
                "def_productTotal_": t["def_total"]
            }}
            ninox_transactions.append(new_record)
        end
        
        conn = Faraday.new(
            url: 'https://api.ninox.com/v1/teams/85Qr2bLduF54cjRuY/databases/g132f7q7golx/tables/ME',
            headers: {'Content-Type' => 'application/json', 'Authorization' => "Bearer c54f1a10-be9a-11ed-99d8-55c64db17004"}
        )
          
        response = conn.post('https://api.ninox.com/v1/teams/85Qr2bLduF54cjRuY/databases/g132f7q7golx/tables/ME/records') do |req|
            req.body = ninox_transactions.to_json
        end

        response 

    end

    def post_driver_table(drivers)
        
        drivers_data_to_create = []
        drivers_data_to_update = []

        drivers.each do |driver|
            hr = get_duration_hrs_and_mins(driver["cycleRemaining"])
            
            
            if !driver["vehicleName"].empty?
                print driver["driverId"]
                driver_obj = Driver.where(samsara_id: driver["driverId"]).first

                print driver_obj

                if driver_obj.nil?
                    driver_obj = Driver.new(
                        samsara_id: driver["driverId"],
                        name_on_system: driver["driverName"],
                        truck: driver["vehicleName"],
                        current_status: driver["currentDutyStatusCode"],
                        cycle_remainind: hr
                    )
                    driver_obj.save
                    drivers_data_to_create << {"fields": {
                        "name_on_system_": driver["driverName"],
                        "samsara_id_": driver["driverId"],
                        "last_truck_reported_": driver["vehicleName"],
                        "current_status_": driver["currentDutyStatusCode"],
                        "cycle_remaining_": hr
                    }}
                else

                    drivers_data_to_update << {"fields": {
                        "ninox_id": driver_obj.ninox_id,
                        "name_on_system_": driver["driverName"],
                        "samsara_id_": driver["driverId"],
                        "last_truck_reported_": driver["vehicleName"],
                        "current_status_": driver["currentDutyStatusCode"],
                        "cycle_remaining_": hr
                    }}
                    driver_obj.current_status = driver["currentDutyStatusCode"]
                    driver_obj.truck = driver["vehicleName"]
                    driver_obj.cycle_remainind = hr
                    driver_obj.save
    
                end
                
            end
        end
        
        conn = Faraday.new(
            url: 'https://api.ninox.com/v1/teams/85Qr2bLduF54cjRuY/databases/g132f7q7golx/tables/BF',
            headers: {'Content-Type' => 'application/json', 'Authorization' => "Bearer c54f1a10-be9a-11ed-99d8-55c64db17004"}
        )

        
          
        if drivers_data_to_update.count > 0
            response_update = []

            #d = drivers_data_to_update[0][:fields].delete(:ninox_id)
            #d = drivers_data_to_update[0][:fields]
            #        return d

            drivers_data_to_update.each do |d|
                ninox_id = d[:fields].delete(:ninox_id)
                response = conn.put("https://api.ninox.com/v1/teams/85Qr2bLduF54cjRuY/databases/g132f7q7golx/tables/BF/records/#{ninox_id}") do |req|
                    
                    req.body = d.to_json
                    
                end
                response_update << response
            end
            return {"updated": response_update}
        end

        if drivers_data_to_create.count > 0
            response = conn.post('https://api.ninox.com/v1/teams/85Qr2bLduF54cjRuY/databases/g132f7q7golx/tables/BF/records') do |req|
                req.body = drivers_data_to_create.to_json
    
                
            end
            drivers_created = JSON.parse(response.body)
            drivers_created.each do |d|
                driver_obj = Driver.where(samsara_id: d["fields"]["samsara_id_"]).first
                if !driver_obj.nil?
                    driver_obj.ninox_id = d["id"]
                    driver_obj.save
                end  
            end

            return {"created": drivers_created}
        end
        


    end

    def get_duration_hrs_and_mins(duration)
        hours = duration / (1000 * 60 * 60)
        minutes = duration / (1000 * 60) % 60
        "#{hours}h"# #{minutes}m" 
      rescue
        ""
      end
end
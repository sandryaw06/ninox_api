module SamsaraHelper
    def create_samsara_connection(params, headers)
        headers['Content-Type'] = 'application/json'
        headers['Authorization'] = 'Bearer samsara_api_DevKsTUTyzrUPpgzm9rCWBfLfYii6p'
        conn = Faraday.new(
            url: 'https://api.samsara.com',
            params: params,
            headers: headers
          )
    end

    def get_vehicles
        conn = create_samsara_connection({},{})
        response = conn.get('/fleet/vehicles')
        response = JSON.parse(response.body)
        response["data"]
    end

    def get_vehicle_odometer
        vehicles_ids = get_vehicles.map{|v| v["id"]}
        vehicles_ids = vehicles_ids.join(",")
        url = "https://api.samsara.com/fleet/vehicles/stats?types=obdOdometerMeters,gps&vehicleIds=#{vehicles_ids}"
        conn = create_samsara_connection({},{})
        response = conn.get(url)
        response = JSON.parse(response.body)
        response["data"].map{ |v|
            {
                name: v["name"],
                odo_miles: v["obdOdometerMeters"].nil? ? "" : (v["obdOdometerMeters"]["value"] *  0.000621371).round,
                gps_location: v["gps"]["reverseGeo"]["formattedLocation"]
            }
        }
    end
    

    def get_drivers_data
        conn = create_samsara_connection({},{})
        response = conn.get('v1/fleet/hos_logs_summary')

        response = JSON.parse(response.body)
        response["drivers"]
    end

end
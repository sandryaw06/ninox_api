
module QuikqHelper

    require 'time'
    require 'date'

    def quikq_authorization(params, headers)

        conn = Faraday.new(
            url: 'https://api.quikq.com/',
            params: {},
            headers: {'Content-Type' => 'application/json'}
          )

        body_credentials = {
            "startCode" => "9510952",
            "userId" => "developer@ltransl.com",
            "password" => "L!ghtn!ng123"
        }
        authorization_token = conn.post('v1/auth',body_credentials.to_json)
        authorization_token = authorization_token.body
        authorization_token = JSON.parse(authorization_token)

        if authorization_token["status"] == "success"
            return "Bearer #{authorization_token["data"]["token"]}"
        else
            return "error"
        end
    end

    def quikq_connection(url, params, headers)
        headers['Authorization'] = quikq_authorization({},{})
        conn = Faraday.new(
            url: "https://api.quikq.com/v1/",
            params: params,
            headers: headers
          )
    end

    def get_week_transaction(startDate,endDate)

        startDate ||= Time.now.strftime("%Y-%m-%dT00:00:00-00:00")
        endDate ||= Time.now.strftime("%Y-%m-%dT23:59:59-00:00")

        auth = quikq_authorization({},{})
        url = "reports/transactions/995926?startCode=995926&startDt="+startDate+"&endDt="+endDate

        conn = quikq_connection(url, {}, {})
        response = conn.get(url)
        response = JSON.parse(response.body)
        response["data"]
    end

    

    def get_product_name(products_data, product_code)
        product = products_data.detect{|p| p["product"]["productCode"] == product_code}
        product["product"]["productName"]

    end

    def get_stop_name(stations, station_code)
        station = stations.detect{|s| s["truckStop"]["station"] == station_code}
        station = station["truckStop"]
        "Loves " + station["storeNumber"] + " " + station["city"] + " " + station["state"]

    end

end
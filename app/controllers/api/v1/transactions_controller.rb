class Api::V1::TransactionsController < ApplicationController
    include QuikqHelper
    include NinoxHelper
    include SamsaraHelper

    def index
       
        # ?from=2023-03-01&to=2023-03-03
        if params[:from].nil? || params[:to].nil?
            @transactions = get_week_transaction(nil,nil)
        else
            @transactions = get_week_transaction("#{params[:from]}T00:00:00-00:00","#{params[:to]}T23:59:00-00:00")
        end
        render json:  post_transaction_table(transform_transactions(@transactions))
    end

    def transform_transactions(transactions)
        result = []

        samsara_data = get_vehicle_odometer

        #print samsara_data

        products_data = transactions["report"]["products"]
        stations = transactions["report"]["truckStops"]
        transactions = transactions["report"]["transactions"]
        
        transactions.each do |transaction|
            transaction = transaction["transaction"]
            subtransactions = transaction["subTransactions"]
            subtransactions.each do |subt|
                subt = subt["subTransaction"]
                prods = subt["productDetails"]
                post_hr = subt["postDate"].split("-")[3].gsub(".",":")
                event_hr = subt["eventDate"].split("-")[3].gsub(".",":")
                products = []
                product_details, product_diesel_qty, product_diesel_cost  = ""
                prods = prods.each do |p|
                    p = p["productDetail"]
                    prod_obj = {
                            product_name: get_product_name(products_data, p["productCode"]),
                            product_code: p["productCode"],
                            product_qty: p["quantity"],
                            product_cost: p["unitCost"]
                    }
                    products << prod_obj
                    if prod_obj[:product_name].include? "Diesel"
                        product_diesel_qty = p["quantity"]
                        product_diesel_cost = p["unitCost"]
                    end
                    
                    product_details = product_details + " --> "+ "#{get_product_name(products_data, p["productCode"])}: #{p["quantity"]} - #{p["unitCost"]}/u   "
                end

                postDate = subt["postDate"].split("-").take(3).join("-")
                eventDate = subt["eventDate"].split("-").take(3).join("-")
                transaction_obj = Transaction.where(truck: transaction["unit"], post_data: postDate, time_post_data: post_hr).first
                
                odometer_obj = samsara_data.detect{|s| s[:name] == transaction["unit"]}
                if transaction_obj.nil?
                    new_t = {
                        truck: transaction["unit"],
                        station: get_stop_name(stations,transaction["station"]),
                        event_data: eventDate,
                        post_data: postDate,
                        postHr: post_hr,
                        eventHr: event_hr,
                        sub_total: subt["subTotal"],
                        odomiles: odometer_obj.nil? ? "" : odometer_obj[:odo_miles],
                        gps_location: odometer_obj.nil? ? "" : odometer_obj[:gps_location],
                        product_details: product_details,
                        product_qty: product_diesel_qty,
                        product_cost: product_diesel_cost,
                        time_post_data: post_hr

                    }
                    result << new_t
                    #[:product_details, :station, :eventDate, :postHr, :eventHr, :odomiles, :gps_location, ].each { |k| new_t.delete(k) }
                    transaction_obj = Transaction.new({
                        truck: new_t[:truck],
                        post_data: postDate,
                        time_post_data: new_t[:time_post_data],
                        sub_total: new_t[:sub_total],
                        event_data: new_t[:event_data],
                        product_qty: new_t[:product_qty],
                        product_cost: new_t[:product_cost]

                    })
                    transaction_obj.save
                
                end
            end
        end
        result
    end
end
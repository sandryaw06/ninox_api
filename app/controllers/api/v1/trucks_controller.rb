class Api::V1::TrucksController < ApplicationController
    include SamsaraHelper

    def save_samsara_vehicles(date)
        data = []
        trucks = get_vehicles
        trucks.each do |t|
            #truck = Truck.find(samsara_id: t["id"]).first
            #print truck
            #if !truck
                new_truck = Truck.new(samsara_id: t["id"], name: t["name"])
                new_truck.save
                data << new_truck
            #end
        end 
       return data
    end


    def index
        data = get_vehicle_odometer
        @trucks  = Truck.all
        render json: data
    end

    def show
        @truck = Truck.where(name: params[:id]).first
        render json: @truck
    end

    def delete_all
        @trucks = Truck.all
        @trucks.each {|t| t.destroy}
        render json: @trucks
    end

end

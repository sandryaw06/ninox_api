class Api::V1::SamsarasController < ApplicationController

    include SamsaraHelper
    include NinoxHelper
    
    def index
        render json: get_vehicle_odometer

    end

    def drivers
        drivers =  get_drivers_data
        
        render json: post_driver_table(drivers)
    end
end

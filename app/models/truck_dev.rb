class TruckDev
  include Mongoid::Document
  include Mongoid::Timestamps
  field :truck, type: String
end

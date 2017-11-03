class Coordinate < ApplicationRecord
  # A model to store previous lookups. basically acts like a cache
  # One thing I might want to add in the future it to set some type of a timeout
  # to expire entries from the cache so that it doesn't grow indefinitely bigger.
  has_one :gas_station, dependent: :destroy
  validates :lat, presence: true
  validates :lng, presence: true

  # geocoder gem gets the address parts for us from the given lat and long
  reverse_geocoded_by :lat, :lng do |obj, results|
    if geo = results.first
      obj.street_address = geo.address.split(",")[0]
      obj.city = geo.city
      obj.state = geo.state_code
      obj.zipcode = geo.postal_code
    end
  end
  after_validation :reverse_geocode

  # Takes in a latitude and longitude as decimals.
  # Returns whether the given coordinate(lat & long) is in the database already
  # and whether you need to make a call to Google Places API
  def self.cached?(lat, long) 
    given_point = [lat, long]
    nearby_points = Coordinate.near(given_point, 0.05).order("distance")
    if nearby_points.length > 0
      return true
    end
    false
  end

  # Takes in a latitude and longitude as decimals.
  # If given coordinate(lat & long) is in the database then this method 
  # returns it otherwise it returns nil
  def self.nearest_coordinate(lat, long)
    given_point = [lat, long]
    nearby_points = Coordinate.near(given_point, 0.05).order("distance")
    nearby_points.first
  end
end

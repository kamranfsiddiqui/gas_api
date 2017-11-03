class Coordinate < ApplicationRecord
  has_one :gas_station, dependent: :destroy
  validates :lat, presence: true
  validates :lng, presence: true
  reverse_geocoded_by :lat, :lng do |obj, results|
    if geo = results.first
      obj.street_address = geo.address.split(",")[0]
      obj.city = geo.city
      obj.state = geo.state_code
      obj.zipcode = geo.postal_code
    end
  end
  after_validation :reverse_geocode

  def self.cached?(lat, long) 
    given_point = [lat, long]
    nearby_points = Coordinate.near(given_point, 0.05).order("distance")
    if nearby_points.length > 0
      return true
    end
    false
  end

  def self.nearest_coordinate(lat, long)
    given_point = [lat, long]
    nearby_points = Coordinate.near(given_point, 0.05).order("distance")
    nearby_points.first
  end
end

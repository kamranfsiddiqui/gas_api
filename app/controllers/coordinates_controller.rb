class CoordinatesController < ApplicationController

  API_KEY = "AIzaSyBOlLQVzq_P_l_gPRyno9bjmWbg0KWwFmk"
  
  # The main api endpoint, expects the latitude and longitude to be passed as query paremeters
  # returns the address of the passed in coordinate as well as the address of the nearest gas station 
  def nearest_gas
    #if the lookup is cached we want to return the cached info
    if not Coordinate.cached?(params[:lat], params[:lng]) 

      # the call to the Google Places API
      @client = GooglePlaces::Client.new(API_KEY)
      closest_stations = @client.spots(params[:lat], params[:lng], radius: 50000, types: ['gas_station'], detail: true).sort {
        |x,y| Geocoder::Calculations.distance_between([params[:lat], params[:lng]], [x.lat, x.lng])<=> Geocoder::Calculations.distance_between([params[:lat], params[:lng]], [y.lat, y.lng])
      }
      closest_station = closest_stations[0]
      
      # if the user calls endpoint with invalid lat and long or if no info available from the Google Places API then render status 400
      if closest_station.nil?
        render plain: {error: "No Gas station Data for this location"}.to_json, status: 400, content_type: 'application/json'
        return
      end

      # add new location to the cache
      current_location = Coordinate.new(coordinate_params)
      current_location.save

      # build response as a ruby hash
      data = nearest_gas_response(closest_station, current_location, false)

      # build new GasStation to add to the database/cache
      cached_station =  GasStation.new
      cached_station.street_address = data[:nearest_gas_station][:streetAddress]
      cached_station.city = data[:nearest_gas_station][:city]
      cached_station.state = data[:nearest_gas_station][:state]
      cached_station.postal_code = data[:nearest_gas_station][:postal_code] 
      cached_station.coordinates_id = current_location.id

      # add new gas station address to the cache
      cached_station.save 

      #return json response
      render :json => data
    else
      #lookup is cached so no need to make an Google Places API call just return
      current_location = Coordinate.nearest_coordinate(params[:lat], params[:lng])
      closest_station = GasStation.where(coordinates_id: current_location.id).first
      data = nearest_gas_response(closest_station, current_location, true)
      render :json => data
    end
  end

  private
    def coordinate_params
      params.permit(:lat, :lng)
    end

    # builds the api response for nearest_gas as a ruby hash
    def nearest_gas_response(gas_station, current_location, is_cached)
      data = Hash.new
      data[:address] = Hash.new
      data[:address][:streetAddress] = current_location.street_address
      data[:address][:city] = current_location.city
      data[:address][:state] = current_location.state
      data[:address][:postal_code] = current_location.zipcode
      data[:nearest_gas_station] = Hash.new 
      if not is_cached
        gas_station_address = gas_station.address_component("street_number", "long_name") + " " + gas_station.address_component("route", "long_name")
        data[:nearest_gas_station][:streetAddress] = gas_station_address
        data[:nearest_gas_station][:city] = gas_station.address_component("locality", "long_name")
        data[:nearest_gas_station][:state] = gas_station.address_component("administrative_area_level_1", "short_name")
        data[:nearest_gas_station][:postal_code] = gas_station.address_component("postal_code", "long_name")
      else
        data[:nearest_gas_station][:streetAddress] = gas_station.street_address
        data[:nearest_gas_station][:city] = gas_station.city
        data[:nearest_gas_station][:state] = gas_station.state
        data[:nearest_gas_station][:postal_code] = gas_station.postal_code
      end
      data
    end

end

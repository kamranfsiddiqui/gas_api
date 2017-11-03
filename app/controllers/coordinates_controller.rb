class CoordinatesController < ApplicationController

  API_KEY = "AIzaSyBOlLQVzq_P_l_gPRyno9bjmWbg0KWwFmk"
  
  def nearest_gas
    if not Coordinate.cached?(params[:lat], params[:lng]) 
      puts "\n\nuncached response asfdafafdafdalfkd;jafds;l\n\n"
      @client = GooglePlaces::Client.new(API_KEY)
      closest_stations = @client.spots(params[:lat], params[:lng], radius: 50000, types: ['gas_station'], detail: true).sort {
        |x,y| Geocoder::Calculations.distance_between([params[:lat], params[:lng]], [x.lat, x.lng])<=> Geocoder::Calculations.distance_between([params[:lat], params[:lng]], [y.lat, y.lng])
      }
      closest_station = closest_stations[0]
      puts "\n\n #{closest_station.types.to_s} #{closest_station.street}\n\n"
      if closest_station.nil?
        render plain: {error: "No Gas station Data for this location"}.to_json, status: 400, content_type: 'application/json'
        return
      end
      current_location = Coordinate.new(coordinate_params)
      address_parts = Geocoder.address("#{params[:lat]}, #{params[:lng]}").split(",").map {|e| e.strip}
      current_location.street_address = address_parts[0]
      puts "\n\n#{address_parts[0]}\n\n"
      #current_location.city = address_parts[1]
      #current_location.state = address_parts[2].split(" ")[0]
      #current_location.postal_code = address_parts[2].split(" ")[1]
      if not current_location.save
        render plain: {error: "Client Error"}.to_json, status: 400, content_type: 'application/json'
        return
      end
      data = nearest_gas_response(closest_station, current_location, false)
      cached_station =  GasStation.new
      cached_station.street_address = data[:nearest_gas_station][:streetAddress]
      cached_station.city = data[:nearest_gas_station][:city]
      cached_station.state = data[:nearest_gas_station][:state]
      cached_station.postal_code = data[:nearest_gas_station][:postal_code] 
      cached_station.coordinates_id = current_location.id
      if not cached_station.save!
        render plain: {error: "Internal Server Error"}.to_json, status: 500, content_type: 'application/json'
        return
      end
      render :json => data
      #render :json => closest_station.address_components
    else
      puts "\n\ncached response\n\n"
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

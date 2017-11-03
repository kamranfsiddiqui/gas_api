# spec/controllers/coordinates_controller_spec.rb
require 'spec_helper'

describe CoordinatesController do
  describe "GET #nearest_gas" do
    before :each do
      @lat = 37.77801
      @lng = -122.4119076
      @cache_radius = 0.000723  
      @out_of_radius = 0.000732 # a bit more than 0.05 mi so that lat/lng will be outside cache radius
      @point_params = {lat: @lat, lng: @lng, street_address: "1298 Howard Street", city: "San Francisco", state: "CA", zipcode: "94103"}
      @station_params = {street_address: "1298 Howard Street", city: "San Francisco", state: "CA", postal_code: "94103"}
      @expected_response = { 
        address: {streetAddress: "1155 Mission St", city: "San Francisco", state: "CA", postal_code: "94103"},
        nearest_gas_station: {streetAddress: "1298 Howard Street", city: "San Francisco", state: "CA", postal_code: "94103"}
      }.to_json
    end

    context "with cached location" do
      it "returns json with correct information" do
        @point = FactoryBot.create(:coordinate, @point_params)
        @station_params[:coordinates_id] = @point.id
        @station = FactoryBot.create(:gas_station, @station_params)
        get :nearest_gas, params: {lat: @lat, lng:@lng}    
        expect(response.body).to eq(@expected_response)
      end
      it "returns json with correct information for location in cache radius" do
        @point = FactoryBot.create(:coordinate, @point_params)
        @station_params[:coordinates_id] = @point.id
        @station = FactoryBot.create(:gas_station, @station_params)
        get :nearest_gas, params: {lat: @lat+@cache_radius, lng:@lng}    
        expect(response.body).to eq(@expected_response)
      end
    end

    context "with a new location" do
      it "returns json with correct information" do
        get :nearest_gas, params: {lat: @lat, lng:@lng}    
        expect(response.body).to eq(@expected_response)
        get :nearest_gas, params: {lat: 37.7778805,  lng: -122.4121443}
        expect(response.body).to eq(@expected_response)
      end
    end
  end

end

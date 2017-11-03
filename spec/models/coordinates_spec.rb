# spec/models/coordinates_spec.rb
require 'spec_helper'

describe Coordinate do
=begin
  0.05 mi = 80.47 meters = 0.00072493 degrees
=end
  before :each do
    @lat = 37.77801
    @lng = -122.4119076
    @cache_radius = 0.000723  
    @out_of_radius = 0.000732 # a bit more than 0.05 mi so that lat/lng will be outside cache radius
  end

  it "has a valid factory" do
    expect(FactoryBot.create(:coordinate)).to be_valid
  end

  it "is invalid without a latitude" do
    expect(FactoryBot.build(:coordinate, lat: nil)).to_not be_valid
  end

  it "is invalid without a longitude" do
    expect(FactoryBot.build(:coordinate, lng: nil)).to_not be_valid
  end

  describe "method 'cached?' returns whether a location is cached" do

    context "with cached location" do
      it "returns true" do
        @point = FactoryBot.create(:coordinate, lat: @lat, lng: @lng)
        expect(Coordinate.cached?(@lat, @lng+@cache_radius)).to eq(true)
      end
      it "returns true if location is within 0.05 miles from a cached location" do
        @point = FactoryBot.create(:coordinate, lat: @lat, lng: @lng)
        expect(Coordinate.cached?(@lat+@out_of_radius, @lng)).to eq(false)
      end
    end

    context "with uncached location" do
      it "returns false if location is not cached" do
        expect(Coordinate.cached?(@lat, @lng)).to eq(false)
      end
      it "returns false if location is more than 0.05 miles from a cached location" do
        @point = FactoryBot.create(:coordinate, lat: @lat, lng: @lng)
        expect(Coordinate.cached?(@lat+@out_of_radius, @lng)).to eq(false)
      end
    end
  end

  describe  "method 'nearest_coordinate' returns the nearest cached station to given location" do

    context "with cached location" do
      it "returns cached location" do
        @point = FactoryBot.create(:coordinate, lat: @lat, lng: @lng)
        expect(Coordinate.nearest_coordinate(@lat, @lng)).to eq(@point)
      end
      it "returns nearest cached location if given location is within 0.05 miles " do
        @point = FactoryBot.create(:coordinate, lat: @lat, lng: @lng)
        expect(Coordinate.nearest_coordinate(@lat+@cache_radius, @lng)).to eq(@point)
      end
    end

    context "with uncached location" do
      it "returns nil if location is not cached" do
        expect(Coordinate.nearest_coordinate(@lat, @lng)).to eq(nil)
      end
      it "returns nil if location is more than 0.05 miles from a cached location" do
        @point = FactoryBot.create(:coordinate, lat: @lat, lng: @lng)
        expect(Coordinate.nearest_coordinate(@lat+@out_of_radius, @lng)).to eq(nil)
      end
    end

  end

end

# spec/factories/coordinates.rb
#
require 'faker'

FactoryBot.define do
  factory :coordinate do |f|
    f.lat {Faker::Address.latitude}
    f.lng {Faker::Address.longitude}
    f.street_address {Faker::Address.street_address}
    f.city {Faker::Address.city}
    f.state {Faker::Address.state_abbr}
    f.postal_code {Faker::Address.zip}
  end
end

class GasStation < ApplicationRecord
  # A model to store closest gas station to previous lookups. Basically acts like a cache
  # One thing I might want to add in the future it to set some type of a timeout
  # to expire entries from the cache so that it doesn't grow indefinitely bigger.
  belongs_to :coordinate, optional: true
end

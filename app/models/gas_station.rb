class GasStation < ApplicationRecord
  belongs_to :coordinate, optional: true
end

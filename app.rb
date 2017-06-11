require 'sinatra'
require 'nyc_geosupport'
require './bbl_lookup'

GEO = NycGeosupport.client geo_function: '1A'

ERROR_HASH = { status: 'ERROR' }

# Hash -> str
def bbl_hash_to_bbl(h)
  h[:borough] + h[:block] + h[:lot]
end

# Hash -> Hash
def response(wa2)
  {
    bbl: bbl_hash_to_bbl(wa2[:bbl]),
    latitude: wa2[:latitude],
    longitude: wa2[:longitude],
    status: 'OK'
  }
end

def geocode(house, street, boro)
  return ERROR_HASH.merge(message: 'Invalid borough') unless BBL_LOOKUP[boro]

  GEO.run(house_number_display_format: house, street_name1: street, b10sc1: BBL_LOOKUP[boro])

  # successful geocoding
  if GEO.response[:work_area_1][:geosupport_return_code] == '00'
    response(GEO.response[:work_area_2])
  else
    if GEO.response[:work_area_1][:message]
      ERROR_HASH.merge(message: GEO.response[:work_area_1][:message])
    else
      ERROR_HASH
    end
  end

rescue
  ERROR_HASH
end

get '/' do
  content_type :json
  geocode(params['house'], params['street'], params['boro']).to_json
end


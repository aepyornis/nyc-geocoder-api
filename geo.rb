require 'nyc_geosupport'
require 'ruby_postal/parser'
require './bbl_lookup'

GEOSUPPORT = NycGeosupport.client geo_function: '1A'
ERROR_HASH = { status: 'ERROR' }

module Geo
  # String -> Hash
  def self.parse_address(address)
    Postal::Parser.parse_address(address).reduce({}) do |memo, h|
      memo.store(h[:label], h[:value])
      memo
    end
  end

  # Str -> Hash | Str
  def self.address_to_geo_params(str_address)
    address = parse_address(str_address)
    if address.key?(:house_number) && address.key?(:road) && address.key?(:postcode)
      {
        house_number_display_format: address[:house_number],
        street_name1: address[:road],
        zip_code_input: address[:postcode]
      }
    else
      "Could not parse address: #{str_address}"
    end
  end

  # Hash -> Str
  def self.bbl_hash_to_bbl(h)
    h[:borough] + h[:block] + h[:lot]
  end

  # Hash -> Hash
  def self.response(wa2)
    {
      bbl: bbl_hash_to_bbl(wa2[:bbl]),
      latitude: wa2[:latitude],
      longitude: wa2[:longitude],
      status: 'OK'
    }
  end

  # Hash -> Hash
  def self.geocode(params)
    res = parse_params(params)
    if res.is_a? String
      ERROR_HASH.merge(message: res)
    else
      geosupport(res)
    end
  end

  # Hash -> Hash
  def self.geosupport(geo_params)
    GEOSUPPORT.run(geo_params)

    # if geocoding is a success:
    if GEOSUPPORT.response[:work_area_1][:geosupport_return_code] == '00'
      response(GEOSUPPORT.response[:work_area_2])
    elsif GEOSUPPORT.response[:work_area_1][:message]
      ERROR_HASH.merge(message: GEOSUPPORT.response[:work_area_1][:message])
    else
      ERROR_HASH
    end
  rescue
    ERROR_HASH
  end

  # Converts params into the format required by NycGeosupport.
  # possible variations:
  #  - house, street, borough (or borough)
  #  - house, street, zip (or zipcode)
  #  - address (will attempt to parse into house, street, zip)
  # Returns Hash or String
  # If it returns a String then it's a error message
  def self.parse_params(params)
    return address_to_geo_params(params['address']) if params['address'].present?
    return "Missing required parameters" unless (params['house'].present? && params['street'].present?)
    boro = boro_param(params)
    zip = zip_param(params)

    if boro
      return 'Invalid borough' unless BBL_LOOKUP[boro]
      {
        house_number_display_format: params['house'],
        street_name1: params['street'],
        b10sc1: BBL_LOOKUP[boro]
      }
    elsif zip
      return 'Invalid zipcode length' unless zip.length == 5
      {
        house_number_display_format: params['house'],
        street_name1: params['street'],
        zip_code_input: zip
      }
    else
      "Missing parameter: zipcode or borough"
    end
  end

  # Hash -> Str | Nil
  private_class_method def self.boro_param(params)
    if params['borough'] || params['boro']
      (params['borough'] || params['boro']).upcase
    end
  end

  # Hash -> Str | Nil
  private_class_method def self.zip_param(params)
    params['zip'] || params['zipcode']
  end
end

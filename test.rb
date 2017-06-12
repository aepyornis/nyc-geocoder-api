require './geo.rb'

RSpec.describe Geo do
  let(:bbl_hash) { { :borough => '3', :block => '12345', :lot => '0002' } }

  describe 'bbl_hash_to_bbl' do
    it 'returns bbl' do
      expect(Geo.bbl_hash_to_bbl(bbl_hash)).to eq '3123450002'
    end
  end

  describe 'response' do
    it 'returns response hash' do
      wa2 = { bbl: bbl_hash, latitude: 10, longitude: 20 }
      result = { bbl: '3123450002', latitude: 10, longitude: 20, status: 'OK' }
      expect(Geo.response(wa2)).to eq result
    end
  end

  describe 'geosupport' do
    let(:result) do
      { bbl: "3086960212", latitude: 40.57436, longitude: -73.978499, status: 'OK' }
    end
    let(:geo_params) do
      { house_number_display_format: '1000', street_name1: 'Surf Avenue', b10sc1: '3' }
    end
    it 'returns good response' do
      expect(Geo.geosupport(geo_params)).to eq result
    end

    it 'returns error for bad request' do
      expect(Geo.geosupport(location: "i'm right by that place with the awesome pizza"))
        .to eq(status: "ERROR", message: "NO INPUT DATA RECEIVED")
    end
  end

  describe 'geocode' do
    it 'returns error message if given an empty set of params' do
      expect(Geo.geocode({})).to eq({ status: 'ERROR', message: "Missing required parameters" })
    end

    it 'returns geocoded response as hash' do
      result = { bbl: "3086960212", latitude: 40.57436, longitude: -73.978499, status: 'OK' }
      expect(Geo.geocode({"street" => 'Surf Ave', "house" => '1000', "boro" => 'Brooklyn' })).to eq result
    end 
  end

  describe 'parse params' do
    let(:zip_result) do
      {
        house_number_display_format: '1000',
        street_name1: '1st ave',
        zip_code_input: '12345'
      }
    end

    let(:boro_result) do
      {
        house_number_display_format: '1000',
        street_name1: '1st ave',
        b10sc1: '3'
      }
    end

    it 'returns string error if missing house or street' do
      msg = "Missing required parameters"
      expect(Geo.parse_params({})).to eq msg
      expect(Geo.parse_params({'house' => '1000'})).to eq msg
      expect(Geo.parse_params({'street' => '1st ave'})).to eq msg
    end

    it 'returns string error if missing borough or zip' do
      msg = "Missing parameter: zipcode or borough"
      expect(Geo.parse_params({'street' => '1st ave', 'house' => '1000'})).to eq msg
    end

    it 'returns invalid boro if submitted with a bad borough' do
      msg = 'Invalid borough'
      params = { 'house' => '1000', 'street' => '1st ave', 'borough' => '????' }
      expect(Geo.parse_params(params)).to eq msg
    end

    it 'returns parsed params for house, street, borough' do
      params = { 'house' => '1000', 'street' => '1st ave', 'borough' => 'brooklyn' }
      expect(Geo.parse_params(params)).to eq(boro_result)
    end

    it 'returns invalid zip if provided zip that is not 5 chars' do
      msg =  'Invalid zipcode length'
      params = { 'house' => '1000', 'street' => '1st ave', 'zip' => '1234' }
      expect(Geo.parse_params(params)).to eq msg
    end

    it 'returns parsed params for house, street, zip' do
      params_zip = { 'house' => '1000', 'street' => '1st ave', 'zip' => '12345' }
      params_zipcode = { 'house' => '1000', 'street' => '1st ave', 'zipcode' => '12345' }
      expect(Geo.parse_params(params_zip)).to eq(zip_result)
      expect(Geo.parse_params(params_zipcode)).to eq(zip_result)
    end
  end

end



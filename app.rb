require 'sinatra'
require './geo.rb'

class NycGeocodeApi < Sinatra::Base
  get '/' do
    content_type :json
    Geo.geocode(params).to_json
  end
end


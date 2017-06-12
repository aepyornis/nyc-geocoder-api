require 'sinatra'
require './geo.rb'

get '/' do
  content_type :json
  Geo.geocode(params).to_json
end

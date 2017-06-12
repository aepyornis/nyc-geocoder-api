require 'sinatra'
require './geo.rb'

get '/' do
  content_type :json
  geocode(params)
end

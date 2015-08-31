#!/usr/bin/env ruby
require 'sinatra'
require 'json'

set :bind, '0.0.0.0'

get '/event/:uuid/:assay' do
  puts "Requested assay #{params[:assay]} for UUID: #{params[:uuid]}"
end

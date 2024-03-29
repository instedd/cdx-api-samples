#!/usr/bin/env ruby

# Returns the result for a given condition of a single test as a string
# or "N/A" if not available - for any reason

require 'sinatra'
require 'json'
require 'net/http'

set :bind, '0.0.0.0'

HOST = ENV["CDX_HOST"] || "http://cdp2.instedd.org"

CDX_USERNAME = ENV["CDX_USER"] || "user@instedd.org"
CDX_PASSWORD = ENV["CDX_PASS"] || "password"

get '/event/:uuid/:assay' do
  test_uuid = params[:uuid]
  assay_condition = params[:assay]


  uri = URI.parse("#{HOST}/api/events?test.uuid=#{test_uuid}")

  puts uri

  req = Net::HTTP::Get.new(uri.request_uri)
  req.basic_auth CDX_USERNAME, CDX_PASSWORD

  req["Content-Type"] = "application/json"

  res = Net::HTTP.start(uri.hostname, uri.port) {|http|
    http.request(req)
  }

  puts res.body

  response = JSON.parse res.body

  if response["error"] == "You need to sign in or sign up before continuing."
    status 403
    return res.body
  end

  return "N/A" if response["tests"].length != 1

  test = response["tests"].first

  assays = test["test"]["assays"]
  condition = assays.detect {|assay| assay["condition"] == assay_condition}

  return body condition["result"] if condition and condition.has_key? "result"
  body "N/A"
end

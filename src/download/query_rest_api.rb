#!/usr/bin/ruby

require 'net/http'
require 'json'
require_relative '../../config.rb'

def patch_ontology_admin(restURL, ontoAcronym)
  #Change the administeredBy content
  #curl -X PATCH -H "Content-Type: application/json" -H "Authorization: apikey token=#{sifr_apikey}" -d '{"administeredBy": ["jonquet","emonet"]}' http://bioportal.lirmm.fr:8082/ontologies/CIF

  uri = URI.parse(restURL)
  http = Net::HTTP.new(uri.host, uri.port)

  req = Net::HTTP::Patch.new("/ontologies/#{ontoAcronym}")
  #req = Net::HTTP::Patch.new("http://bioportal.lirmm.fr:8082/ontologies/CIF", initheader = {'Content-Type' =>'application/json', 'Authorization' => 'apikey token=#{sifr_apikey}'})

  req['Content-Type'] = "application/json"
  req['Authorization'] = "apikey token=#{sifr_apikey}"
  #req.add_field('Content-Type', 'application/json')

  req.body = {:administeredBy => ['jonquet','emonet']}.to_json

  #response = http.request(req)
  response = http.start do |http|
    http.request(req)
  end

  return response

end

ontology_array = ['BHN', 'CIF', 'CCAM', 'CIM-10', 'CISP-2', 'LPP', 'MEDLINEPLUS', 'NABM', 'SNMIFRE', 'WHO-ARTFRE']

ontology_array.each do |onto|
  puts onto
  puts patch_ontology_admin("http://bioportal.lirmm.fr:8082", onto)
end


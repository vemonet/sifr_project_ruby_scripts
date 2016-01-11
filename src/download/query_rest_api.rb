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

def get_ncbo_ontologies_array
  ontologies_json = JSON.parse(Net::HTTP.get(URI.parse('http://data.bioontology.org/ontologies?apikey=')))
  puts ontologies_json.class

  ontologies_array = []

  ontologies_json.each do |onto|
    ontologies_array.push(["#{onto['name']} (#{onto['acronym']})", onto['acronym']])
  end
  return ontologies_array
end

def get_annotator_json
  query = "http://vm-bioportal-vincent:8082/annotator/?text=Pseudotruncus+arteriosus&apikey=&include=prefLabel&expand_class_hierarchy=true&class_hierarchy_max_level=1&longest_only=false&recognizer=&exclude_numbers=false&whole_word_only=true&exclude_synonyms=false"
  #query = "http://vm-bioportal-vincent:8080/annotator?text=Pseudotruncus+arteriosus&apikey=&include=prefLabel&expand_class_hierarchy=true&class_hierarchy_max_level=1&longest_only=false&recognizer=&exclude_numbers=false&whole_word_only=true&exclude_synonyms=false"
  uri = URI.parse(query)
  puts Net::HTTP.get(URI.parse(query))

  result = Net::HTTP.start(uri.host, uri.port) {|http|
    http.get(uri.request_uri)
  }

  p result['content-type'] # "text/xml; charset=UTF-8" <- correct
  #p result.content_type # "text/xml" <- incorrect; truncates the charset field
  puts result.body.encoding # ASCII-8BIT <- incorrect encoding, should be UTF-8

end

def define_ontology_types
  portal_api_url = "http://data.stageportal.lirmm.fr"

  # Get list of ontologies in the portal
  json_ontologies = JSON.parse(Net::HTTP.get(URI.parse("#{portal_api_url}/ontologies?apikey=#{vm_apikey}")), {:symbolize_names => true})
  # JSON keys have been symbolized

  uri = URI.parse(portal_api_url)
  http = Net::HTTP.new(uri.host, uri.port)

  # iterate over the ontology list
  json_ontologies.each do |onto|
    # add ontologyType if there is not already one
    if onto[:ontologyType].nil?
      req = Net::HTTP::Patch.new("/ontologies/#{onto[:acronym].to_s}")
      req['Content-Type'] = "application/json"
      req['Authorization'] = "apikey token=#{vm_apikey}"
      req.body = {:ontologyType => "ONTOLOGY"}.to_json

      response = http.start do |http|
        http.request(req)
      end

      puts "Defining ontologyType for: #{onto[:acronym].to_s}"
      puts "Response status : #{response.code} #{response.body}"
      puts " "

    else
      puts "#{onto[:acronym].to_s} : ontologyType already defined"
      puts " "
    end
    sleep 0.5
  end
end



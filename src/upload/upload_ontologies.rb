#!/usr/bin/ruby

require 'net/http'
require 'json'
require_relative '../../config.rb'
require_relative 'ontology_uploader.rb'


# A little script to automatically upload ontologies in a BioPortal Virtual appliance
#

restUrl = "http://vm-bioportal-vincent:8080"
#restUrl = "http://data.stageportal.lirmm.fr"
apikey = vm_apikey
user = "admin"

ontoJson = "../../ontology_files/upload_list_files/ontologies_v1_0.json"

# The folder where the ontologies are:
ontologiesPath = "/srv/data/ontologies"


ontologyUploader = OntologyUploader.new(restUrl, apikey, user)

file = File.read(ontoJson)

ontologiesArray = JSON.parse(file)


ontologiesArray.each do |onto|
  puts onto["acronym"]
  puts ontologyUploader.create_ontology(onto)
  puts ontologyUploader.upload_submission(onto, ontologiesPath)
end


# chown -R ncbobp:ncbobp /srv/data/
#!/usr/bin/ruby

require 'net/http'
require 'json'
require_relative '../../config.rb'
require_relative 'ontology_uploader.rb'

apikey = vm_apikey
user = "admin"
restUrl = "http://vm-bioportal-vincent:8080"

contact = "Vincent Emonet"
mail = "vincent.emonet@lirmm.fr"



ontologyUploader = OntologyUploader.new(restUrl, apikey, user, contact, mail)

#puts ontologyUploader.create_ontology("MDRFRE", "MedDRA, version française")

puts ontologyUploader.upload_submission("MDRFRE", "MedDRA en version française", "/home/emonet/ruby_workspace/sifr_project_ruby_scripts/ontology_files/bp_v2.4/v1_no_modif/MDRFRE.ttl")

#puts ontologyUploader.upload_submission("MDRFRE", "MedDRA en version française", "https://web.archive.org/web/20111213110713/http://www.movieontology.org/2010/01/movieontology.owl")
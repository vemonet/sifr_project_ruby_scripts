#!/usr/bin/ruby

#require 'rubygems'
require 'json'
require 'net/http'
require_relative '../../config.rb'
require_relative 'bio_portal_ontology.rb'

# TODO: Change download path directories

def ddl_main_format_ontologies
  #Download ontologies in their main format (OWL, UMLS or OBO)

  json_onto_list = File.read('../../ontology_files/bioportal_ontologies.json')
  #json_onto_list = Net::HTTP.get(URI.parse('http://data.bioontology.org/ontologies?apikey="#{ncbo_apikey}"'))


  format_hash = {'OBO' => 'obo', 'OWL' => 'owl', 'UMLS' => 'ttl', 'error' => 'txt'}

  json_obj_onto_list = JSON.parse(json_onto_list)

  json_obj_onto_list.each do |onto|
    ontology = BioPortalOntology.new(onto['acronym'])

    fileExist = false
    if File.exist?('../../ontology_files/main_format_ontology_files/' + ontology.acronym + '.owl')
      fileExist = true
    else
      if File.exist?('../../ontology_files/main_format_ontology_files/' + ontology.acronym + '.obo')
        fileExist = true
      else
        if File.exist?('../../ontology_files/main_format_ontology_files/' + ontology.acronym + '.ttl')
          fileExist = true
        else
          if File.exist?('../../ontology_files/main_format_ontology_files/' + ontology.acronym)
            fileExist = true
          else
            if File.exist?('../../ontology_files/main_format_ontology_files/' + ontology.acronym + '.xrdf')
              fileExist = true
            end
          end
        end
      end
    end

    if fileExist == false
      ontology.ddl_url = onto['links']['download'] + "?apikey=#{ncbo_apikey}"
      begin
        json_last_sub = JSON.parse(Net::HTTP.get(URI.parse(onto['links']['latest_submission'] + "?apikey=#{ncbo_apikey}&include=all")))
        ontology.format = json_last_sub['hasOntologyLanguage']
      rescue
        ontology.format = "error"
      end
      puts ontology.acronym
      puts ontology.format

      File.open("main_format_ontology_files/#{ontology.acronym}.#{format_hash[ontology.format]}", "wb") do |file|
        file.write(Net::HTTP.get(URI.parse(ontology.ddl_url)))
      end

    else
      puts ontology.acronym + ' : DONE'
    end

  end


end

def ddl_xrdf_ontologies
  # ddl ontologies in xrdf format for OWL and OBO ontologies

  json_onto_list = File.read('../../ontology_files/bioportal_ontologies.json')
  #json_onto_list = Net::HTTP.get(URI.parse('http://data.bioontology.org/ontologies?apikey=4a5011ea-75fa-4be6-8e89-f45c8c84844e'))

  json_obj_onto_list = JSON.parse(json_onto_list)

  json_obj_onto_list.each do |onto|
    ontology = BioPortalOntology.new(onto['acronym'])

    fileExist = false
    if File.exist?('../../ontology_files/xrdf_ontology_files/' + ontology.acronym + '.xrdf')
      fileExist = true
    end

    if fileExist == false
      ontology.ddl_url = onto['links']['download'] + "?apikey=#{ncbo_apikey}&download_format=rdf"

      json_last_sub = JSON.parse(Net::HTTP.get(URI.parse(onto['links']['latest_submission'] + "?apikey=#{ncbo_apikey}&include=all")))
      ontology.format = json_last_sub['hasOntologyLanguage']

      if ontology.format == "OWL" || ontology.format == "OBO"
        puts ontology.acronym

        File.open("../../ontology_files/xrdf_ontology_files/#{ontology.acronym}.xrdf", "wb") do |file|
          file.write(Net::HTTP.get(URI.parse(ontology.ddl_url)))
        end
      end

    else
      puts ontology.acronym + ' : DONE'
    end

  end

end

def ddl_ontologies_views
  # ddl ontologies in xrdf format for OWL and OBO ontologies

  json_onto_list = File.read('../../ontology_files/bioportal_ontologies.json')
  #json_onto_list = Net::HTTP.get(URI.parse('http://data.bioontology.org/ontologies?apikey=4a5011ea-75fa-4be6-8e89-f45c8c84844e'))


  json_obj_onto_list = JSON.parse(json_onto_list)

  json_obj_onto_list.each do |onto|

    ontology = BioPortalOntology.new(onto['acronym'])

    ontology.ddl_url = onto['links']['download'] + "?apikey=#{ncbo_apikey}&download_format=rdf"

    json_views = JSON.parse(Net::HTTP.get(URI.parse(onto['links']['views'] + "?apikey=#{ncbo_apikey}")))
    puts onto['links']['views']

    if json_views != nil
      begin
        json_views.each do |view|
          fileExist = false
          if File.exist?('../../ontology_files/xrdf_view_files/' + view['acronym'] + '.xrdf')
            fileExist = true
          end
          if fileExist == false
            puts view['acronym']
            puts '__'
            File.open("../../ontology_files/xrdf_view_files/#{view['acronym']}.xrdf", "wb") do |file|
              file.write(Net::HTTP.get(URI.parse(view['links']['download'] + "?apikey=#{ncbo_apikey}&download_format=rdf")))
            end
          else
            puts "#{view['acronym']} : DONE"
          end
        end
      rescue
        puts 'error'
      end
    end


  end

end


ddl_xrdf_ontologies




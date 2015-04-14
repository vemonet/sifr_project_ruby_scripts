#!/usr/bin/ruby

require 'json'
require 'net/http'

#Analyse un fichier owl ou ttl (umls) pour extraire les langues utilisées
def get_ontology_lang(filepath, format)
  ontology_file = File.read(filepath)
  lang_array = []
  puts filepath

  ontology_file.each_line do |line|
    if format == "owl"
      regex_get_lang = line.scan(/xml:lang="(.{2})/)
    elsif format == "ttl"
       regex_get_lang = line.scan(/"@(.{3})/)
    end

    if not lang_array.include? regex_get_lang[0]
      if regex_get_lang[0] != nil
        lang_array.push(regex_get_lang[0])
      end
    end
  end
  return lang_array
end

#Utilise get_ontology_lang pour extraire les langues d'un fichier et les enregistrer dans un CSV
def extract_languages(format)
  File.open("results/#{format}_ontologies_lang.csv", "wb") do |file|
    Dir.glob('xrdf_ontology_files/*.'+ format) do |item|
      acronym = item.scan(/xrdf_ontology_files\/(.*)\./)
      ontology_lang_array = get_ontology_lang(item, format)
      #if ontology_lang_array.include? "fr"
      file.write("#{acronym[0][0]},#{ontology_lang_array.join(",")}\n")
      #end
    end
  end
end

extract_languages("ttl")






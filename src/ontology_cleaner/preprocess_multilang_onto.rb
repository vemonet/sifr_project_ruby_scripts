#!/usr/bin/ruby
require 'rdf'
#require 'rdf-rdfxml'
require 'C:\Ruby21-x64\lib\ruby\gems\2.1.0\gems\rdf-rdfxml-1.1.4\lib\rdf\rdfxml.rb'




RDF::RDFXML::Reader.open("test_files/ONTOTOXNUC.owl") do |reader|
  reader.each_statement do |statement|
    puts statement.inspect
  end
end


=begin
require 'rdf/ntriples'

graph = RDF::Graph.load("http://ruby-rdf.github.com/rdf/etc/doap.nt")
query = RDF::Query.new({
  :person => {
    RDF.type  => FOAF.Person,
    FOAF.name => :name,
    FOAF.mbox => :email,
  }
})

query.execute(graph) do |solution|
  puts "name=#{solution.name} email=#{solution.email}"
end
=end
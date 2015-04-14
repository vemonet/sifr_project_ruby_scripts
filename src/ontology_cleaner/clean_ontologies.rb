#!/usr/bin/ruby

require_relative 'ontology_cleaner.rb'


#input_dir = "C:/Users/Vincent/Documents/ruby_workspace/sifr_project_scripts/ontology_files/ontology_files_to_clean/*.*"
#output_dir = 'C:/Users/Vincent/Documents/ruby_workspace/sifr_project_scripts/ontology_files/ontology_files_cleaned'

input_dir = "../../ontology_files/ontology_files_to_clean/*.*"
output_dir = "../../ontology_files/ontology_files_cleaned/"


def clean_ontology(filepath, filename, fileformat, output_dir)
  # A function that extract literal from owl and ttl files and create a OntologyCleaner to clean this literal depending on
  #the ontology (different ontologies, different cleaning to process)

  ontology_file = File.read(filepath)

  File.open("#{output_dir}#{filename}.#{fileformat}", "wb") do |outputFile|
    #Go through the ontology file line by line
    ontology_file.each_line do |line|

      #extract label to process from the line
      if fileformat == "owl"
        regex_get_literal = line.scan(/<.* xml:lang="fr">(.*)<\/.*>/)
      elsif fileformat == "ttl"
        regex_get_literal = line.scan(/skos:prefLabel """(.*)"""/)
      end

      #"clean" the label (depending on which ontology it is from)
      if regex_get_literal.any?
        clean_literal = OntologyCleaner.new(filename, fileformat, regex_get_literal[0][0])
        clean_literal = clean_literal.clean
        clean_line = line.sub(regex_get_literal[0][0], clean_literal)

        #Remove ID from labels in CIM-10 and CCAM and put it in a skos:altLabel
        if filename == 'CIM-10' || filename == 'CCAM'
          regex_get_prefix = clean_line.scan(/>(([A-Z0-9.)(-]+) - )/)
          if regex_get_prefix.any?
            clean_line = clean_line.gsub(regex_get_prefix[0][0], '')
            clean_line = clean_line + '        <skos:altLabel xml:lang="fr">' + regex_get_prefix[0][1] + '</skos:altLabel>
'
          end
        end

      else
        clean_line = line
      end

      outputFile.write(clean_line)
    end
  end

end

#generate the OntologyCleaner dictionnary to correct french words without accents
OntologyCleaner.fill_dictionnary


#Go through all ontology files in the input_dir and use the clean_ontology function
Dir.glob(input_dir) do |filepath|
  puts filepath
  filename = filepath.scan(/.*\/(.*)\.([a-z]*)/)
  clean_ontology(filepath, filename[0][0], filename[0][1], output_dir)
  puts filename
end

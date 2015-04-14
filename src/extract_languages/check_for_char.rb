#!/usr/bin/ruby

require 'json'
require 'net/http'


def get_char_line(file)
  ontology_file = File.read(file, :encoding => 'utf-8')
  puts file

  line_array = []
  ontology_file.each_line do |line|
    if line.include?("ç")
      #puts line
      line_array.push(line)
    end
  end
  return line_array
end

#Utilise get_ontology_lang pour extraire les langues d'un fichier et les enregistrer dans un CSV
def extract_char_all
  File.open("../../ontology_files/results/check_for_char.txt", "wb") do |output_file|
    Dir.glob('ontology_files/*.*') do |input|
      acronym = input.scan(/ontology_files\/(.*)\./)
      line_array = get_char_line(input)
      if line_array.any? == true
        output_file.write("#{acronym[0][0]} \n #{line_array.join('')}")
      end
    end
  end
end

def extract_test
  File.open("../../ontology_files/check_for_char.txt", "wb") do |output_file|
    input = "../../ontology_files/ontology_files_ncbo_french/ONTOAD.owl"
    acronym = input.scan(/ontology_files\/(.*)\./)
    line_array = get_char_line(input)
    if line_array.any? == true
      output_file.write("#{acronym[0][0]} \n #{line_array.join('')}")
    end
  end
end

extract_char_all
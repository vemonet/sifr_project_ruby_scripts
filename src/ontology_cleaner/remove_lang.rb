#!/usr/bin/ruby

input_dir = "../../ontology_files/cmo/*"
output_dir = "../../ontology_files/lso"
keep_lang = "en"


# Simply remove all lines that have a xml:lang different from keep_lang
# Used particularly to remove fr from biorefinery.owl
def clean_from_lang(inputpath, keep_lang, outputpath)

  input_file = File.read(inputpath)

  File.open(outputpath, "wb") do |outputFile|
    #Go through the ontology file line by line
    input_file.each_line do |line|

      # Remove all lines that have a xml:lang different from keep_lang
      regex_get_lang = line.scan(/<.* xml:lang="([a-z]*)">(.*?)<\/.*>/)
      if regex_get_lang.any?
        if regex_get_lang[0][0] != keep_lang
          line = ""
        end
      end

      outputFile.write(line)
    end
  end

end


#Go through all ontology files in the input_dir and use the clean_ontology function
Dir.glob(input_dir) do |filepath|
  puts filepath
  filename = filepath.scan(/.*\/(.*)/)
  clean_from_lang(filepath, keep_lang, "#{output_dir}/#{filename[0][0]}")
  puts filename
end



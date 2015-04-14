class OntologyCleaner

  @@french_hash = {}
  attr_accessor :ontology, :format, :literal

  def initialize(ontology, format, literal)
    @ontology=ontology
    @format=format
    @literal=literal
  end

  def self.dict
    return @@dict_array
  end

  def self.fill_dictionnary
    dict_filepath = "french_dictionnary.txt"
    dict_file = File.read(dict_filepath, :encoding => 'utf-8')
    replace_hash = {'é' => 'e', 'è' => 'e', 'ê' => 'e', 'ë' => 'e',
                    'ô' => 'o', 'ö' => 'o',
                    'î' => 'i', 'ï' => 'i',
                    'à' => 'a', 'â' => 'a',
                    'û' => 'u'}
    dict_file.each_line do |line|
      line = line.delete!("\n")
      no_accent = line
      replace_hash.each do |key, value|
        no_accent = no_accent.gsub(key, value)
      end
      if @@french_hash[no_accent].nil?
        @@french_hash[no_accent] = line
      else
        #If conflict, then take the solution with the fewer accentuated character
        if @@french_hash[no_accent].scan(/[éèêëôöîïàâû]/).count > line.scan(/[éèêëôöîïàâû]/).count
          @@french_hash[no_accent] = line
        end
      end
    end
  end

  def clean
    case @ontology
      when'BHN'
        clean_cismef
      when 'CCAM'
        clean_cismef
        clean_abbreviation
        clean_ccam
      when 'CIF'
        clean_cismef
      when 'CIM-10'
        clean_cismef
        clean_abbreviation
        @literal = @literal.gsub(' | ', ' ')
      when 'CISP2'
        clean_cismef
        clean_abbreviation
      when 'LPP'
        clean_cismef
      when 'MEDLINEPLUS'
        clean_cismef
      when 'NABM'
        clean_cismef
        clean_caps_lock
        clean_accents
      when 'SNOMED_int'
        clean_cismef
      when 'WHO-ART'
        clean_cismef
        clean_abbreviation
        clean_accents
      when 'ICPCFRE'
        clean_abbreviation
        clean_accents
      when 'MTHMSTFRE'
        clean_accents
      when 'WHOFRE'
        clean_caps_lock
        clean_accents
      when 'ONTOPNEUMO'
        #clean_english_prefLabel
        #clean_espace_dans_mots
        #clean_accents
      when 'ONTOMA'
        clean_underscore
    end

    return @literal
  end


  private
  def clean_cismef
    @literal = @literal.gsub('___', ' : ').gsub('_', ' ').gsub('&apos;', "'").gsub('&quot;', '"').gsub('&gt;', '>').gsub('&lt;', '<')
  end

  def clean_underscore
    @literal = @literal.gsub('_', ' ')
  end

  def clean_caps_lock
    @literal = @literal.downcase
  end

  def clean_accents
    #puts @literal.split
    result_literal = ''
    @literal.split.each do |word|
      if !(@@french_hash[word.downcase].nil?)
        result_literal = result_literal + ' ' + @@french_hash[word.downcase]
      else
        result_literal = result_literal + ' ' + word
      end

    end

    @literal = result_literal.lstrip.capitalize
  end

  def clean_abbreviation
    #Replace abbreviations for some ontologies
    replace_hash = {
        'ICPCFRE' => {'syst' => 'système', 'chron' => 'chronique', 'probl' => 'problème', 'comport' => 'comportement', 'sympt' => 'symptome',
                      'reperc' => 'répercussion', 'org' => 'organes', 'anomal' => 'anomalie', 'dig' => 'digestif'},
        'CCAM' => {'resp.' => 'respiratoire', 'exam.' => 'examen', 'prod.' => 'production', 'aig.' => 'aigue',
                   'insuf.' => 'insuffisance', 'ventil.' => 'ventilation'},
        'CIM-10' => {'<p>' => '', '<P>' => ''},
        'CISP2' => {'resp.' => 'respiratoire', 'modific.' => 'modification', 'lymph.' => 'lymphatique', 'traumat.' => 'traumatique',
                    'pulm.' => 'pulmonaire', 'comport.' => 'comportement'},
        'WHO-ART' => {'sensat ' => 'sensation ', 'synd ' => 'syndrôme ', 'sclerose' => 'sclérose', 'doul '=> 'douleur', 'erytheme' => 'érythème',
                      'tumefaction' => 'tuméfaction', 'necrose' => 'nécrose', 'anesthesie' => 'anesthésie', 'hemarthrose' => 'hémarthrose',
                      'sensibilite' => 'sensibilité', 'reaction' => 'réaction', 'endarterite' => 'endartérite', 'panarterite' => 'panartérite',
                      'arterite' => 'artérite'}
    }
    replace_hash[@ontology].each do |key, value|
      @literal = @literal.downcase.gsub(key, value).capitalize
    end
  end

  def clean_ccam
    @literal = @literal.sub(/ [A-Z]{2}$/, '')
  end


end
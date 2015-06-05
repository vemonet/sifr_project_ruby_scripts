#!/usr/bin/ruby

require 'net/http'
require 'json'
require_relative '../../config.rb'
require_relative 'ontology_uploader.rb'


# A little script to automatically upload ontologies in a BioPortal Virtual appliance
#

restUrl = "http://vm-bioportal-vincent:8080"
apikey = vm_apikey
user = "admin"

contact = "Vincent Emonet"
mail = "vincent.emonet@lirmm.fr"

# The folder where the ontologies are:
ontologiesPath = "/srv/data/ontologies"

# Arrays of hash containing the informations needed to upload the ontologies (acronym, name, description and uploadPath)
# Array for the version 1 ontologies (not corrected)
ontologiesV1 = [
    {:acronym => "MTHMSTFRE",
     :name => "Terminologie minimale standardisée en endoscopie digestive",
     :description => "French translation of International Classification of Primary Care ",
     :uploadPath => "#{ontologiesPath}/v1/MTHMSTFRE.ttl"},

    {:acronym => "ONTOPNEUMO",
     :name => "Ontology of Pneumology",
     :description => 'Ontology of pneumology (french version). The ONTOPNEUMO ontology was developped by Audrey Baneyx, under the direction of Jean Charlet about knowledge engineering expertise and by François-Xavier Blanc in collaboration with Bruno Housset about medical expertise. The OWL compliant ONTOPNEUMO ontology is available under Creative Commons license “Attribution-Non-Commercial-No Derivative Works 2.0 UK”. Details of this license are accessible at : http://creativecommons.org/licenses/ by-nc-nd/2.0/uk/. ',
     :uploadPath => "#{ontologiesPath}/v1/ONTOPNEUMO.owl"},

    {:acronym => "CIF",
     :name => "Classification Internationale du Fonctionnement, du handicap et de la santé",
     :description => "La CIF, adoptée par l'Assemblée Mondiale de la Santé en 2001, remplace la Classification Internationale des Handicaps : déficiences, incapacités, désavantages. Cette classification traduit l'évolution internationale des représentations sociales du handicap au cours des trente dernières années. À l'approche traditionnelle du handicap comme caractéristique individuelle ont été opposées des approches sociales du handicap, souvent radicales, interrogeant la place faite aux personnes handicapées dans la société et la discrimination dont elles sont l'objet par défaut d'accessibilité environnementale et d'accès aux droits communs.",
     :uploadPath => "#{ontologiesPath}/v1/CIF.owl"},

    {:acronym => "HRDO",
     :name => "Disease core ontology applied to Rare Diseases",
     :description => "This resource was designed during a PhD in medical informatics (funded by INSERM, 2010-2012). Its components are (i) a core ontology consistent with a metamodel (disorders and groups of disorders, genes, clinical signs and their relations) and (ii) an instantiation of this metamodel with Orphanet Data (available on http://orphadata.org). </ br> Research experiments demonstrated (i) efficient classifications generation based on SPARQL Construct, (ii) perspectives in semantic audit of a knowledge base, (iii) semantic comparison with OMIM (www.omim.org) using proximity measurements and (iv) opened perspectives in knowledge sharing (LORD, http://lord.bndmr.fr). Current production services of Orphanet developed ORDO, released in 2014, an ontology synchronized with their production database. This ontology is now available on Bioportal.",
     :uploadPath => "#{ontologiesPath}/v1/HRDO.owl"},

    {:acronym => "MDRFRE",
     :name => "Dictionnaire médical pour les activités règlementaires en matière de médicaments",
     :description => "Traduction française du International Classification of Primary Care (MedDRA : Medical Dictionary for Regulatory Activities)",
     :uploadPath => "#{ontologiesPath}/v1/MDRFRE.ttl"},

    {:acronym => "MSHFRE",
     :name => "Medical Subject Headings, version française",
     :description => "Traduction française de Medical Subject Headings (UMLS)",
     :uploadPath => "#{ontologiesPath}/v1/MSHFRE.ttl"},

    {:acronym => "ONTOMA",
     :name => "Ontologie de la médecine alternative",
     :description => "Traduction française de Ontology of Alternative Medicine : common concepts for communication between traditional medicine and western medicine.",
     :uploadPath => "#{ontologiesPath}/v1/ONTOMA.owl"},

    {:acronym => "ONTOTOXNUC",
     :name => "Ontology of Nuclear Toxicity",
     :description => "Traduction française de Ontology of Nuclear Toxicity développée pendant le projet ToxNuc",
     :uploadPath => "#{ontologiesPath}/v1/ONTOTOXNUC.owl"},

    {:acronym => "TOP-MENELAS",
     :name => "Menelas Project Top-Level Ontology",
     :description => "The two main goals MENELAS contributes to are to (i) Provide better account of and better access to medical information through natural languages in order to help physicians in their daily practice, and to (ii) Enhance European cooperation by multilingual access to standardised medical nomenclatures. The major achievements of MENELAS are the realisation of its two functional systems: (i) The Document Indexing System encodes free text PDSs into both an internal representation (a set of Conceptual Graphs) and international nomenclature codes (ICD-9-CM). Instances of the Document Indexing System have been realised for French, English and Dutch ; (ii) The Consultation System allows users to access the information contained in PDSs previously indexed by the Document Indexing System. The test domain for the project was coronary diseases. The existing prototype shows promising results for information retrieval from natural language PDSs and for automatically encoding PDSs into an existing classification such as ICD-9-CM. A set of components, tools, knowledge bases and methods has also been produced by the project. These include language-independent ontology and models for the domain of coronary diseases; conceptual description of the relevant ICD-9-CM codes. This ontology includes a top-ontology, a top-domain ontology and a domain ontology (Coronay diseases surgery). The menelas-top ontology here is the part of the whole ontology without any reference to medical domain. ",
     :uploadPath => "#{ontologiesPath}/v1/TOP-MENELAS.owl"},

    {:acronym => "WHOFRE",
     :name => "OMS Terminologie des Effets Indésirables",
     :description => "Traduction française de WHO Adverse Reaction Terminology (WHO-ART)",
     :uploadPath => "#{ontologiesPath}/v1/WHOFRE.ttl"},

    {:acronym => "CISP2",
     :name => "Classification Internationale des Soins Primaires",
     :description => "Classification Internationale des Soins Primaires, deuxième édition",
     :uploadPath => "#{ontologiesPath}/v1/CISP2.owl"},

    {:acronym => "ICPCFRE",
     :name => "International Classification of Primary Care",
     :description => "International Classification of Primary Care, traduction française, 1993 ",
     :uploadPath => "#{ontologiesPath}/v1/ICPCFRE.ttl"},

    {:acronym => "MEDLINEPLUS",
     :name => "MedlinePlus",
     :description => "MedlinePlus est un site tout public (professionnels, patients, usagers) de la National Library of Medicine (US) proposant de l'information de qualité et concernant la santé. ",
     :uploadPath => "#{ontologiesPath}/v1/MEDLINEPLUS.owl"},

    {:acronym => "SNOMED_int",
     :name => "Systematized Nomenclature of MEDicine",
     :description => "Systematized Nomenclature of MEDicine, version internationale",
     :uploadPath => "#{ontologiesPath}/v1/SNOMED_INT.owl"},

    {:acronym => "WHO-ART",
     :name => "Adverse Reaction Terminology, version francaise",
     :description => "WHO-ART est une terminologie utilisée pour le codage et l'analyse des données de pharmacovigilance, développée par Uppsala Monitoring Centre, employée aussi bien par les pays membres de l'OMS que dans le monde entier par les compagnies pharmaceutiques et organismes de recherche clinique. Le système terminologique WHO-ART s'applique à coder les effets indésirables des médicaments et elle couvre la plupart des termes médicaux nécessaires dans ce domaine.",
     :uploadPath => "#{ontologiesPath}/v1/WHO-ART.owl"}
]

# Array for the version 2 ontologies (corrected)
ontologiesV2 = [
    {:acronym => "MTHMSTFRE",
     :name => "Terminologie minimale standardisée en endoscopie digestive",
     :description => "French translation of International Classification of Primary Care ",
     :uploadPath => "#{ontologiesPath}/v2/MTHMSTFRE.ttl"},

    {:acronym => "ONTOPNEUMO",
     :name => "Ontology of Pneumology",
     :description => 'Ontology of pneumology (french version). The ONTOPNEUMO ontology was developped by Audrey Baneyx, under the direction of Jean Charlet about knowledge engineering expertise and by François-Xavier Blanc in collaboration with Bruno Housset about medical expertise. The OWL compliant ONTOPNEUMO ontology is available under Creative Commons license “Attribution-Non-Commercial-No Derivative Works 2.0 UK”. Details of this license are accessible at : http://creativecommons.org/licenses/ by-nc-nd/2.0/uk/. ',
     :uploadPath => "#{ontologiesPath}/v2/ONTOPNEUMO.owl"},

    {:acronym => "CIF",
     :name => "Classification Internationale du Fonctionnement, du handicap et de la santé",
     :description => "La CIF, adoptée par l'Assemblée Mondiale de la Santé en 2001, remplace la Classification Internationale des Handicaps : déficiences, incapacités, désavantages. Cette classification traduit l'évolution internationale des représentations sociales du handicap au cours des trente dernières années. À l'approche traditionnelle du handicap comme caractéristique individuelle ont été opposées des approches sociales du handicap, souvent radicales, interrogeant la place faite aux personnes handicapées dans la société et la discrimination dont elles sont l'objet par défaut d'accessibilité environnementale et d'accès aux droits communs.",
     :uploadPath => "#{ontologiesPath}/v2/CIF.owl"},

    {:acronym => "HRDO",
     :name => "Disease core ontology applied to Rare Diseases",
     :description => "This resource was designed during a PhD in medical informatics (funded by INSERM, 2010-2012). Its components are (i) a core ontology consistent with a metamodel (disorders and groups of disorders, genes, clinical signs and their relations) and (ii) an instantiation of this metamodel with Orphanet Data (available on http://orphadata.org). </ br> Research experiments demonstrated (i) efficient classifications generation based on SPARQL Construct, (ii) perspectives in semantic audit of a knowledge base, (iii) semantic comparison with OMIM (www.omim.org) using proximity measurements and (iv) opened perspectives in knowledge sharing (LORD, http://lord.bndmr.fr). Current production services of Orphanet developed ORDO, released in 2014, an ontology synchronized with their production database. This ontology is now available on Bioportal.",
     :uploadPath => "#{ontologiesPath}/v2/HRDO.owl"},

    {:acronym => "ONTOMA",
     :name => "Ontologie de la médecine alternative",
     :description => "Traduction française de Ontology of Alternative Medicine : common concepts for communication between traditional medicine and western medicine.",
     :uploadPath => "#{ontologiesPath}/v2/ONTOMA.owl"},

    {:acronym => "ONTOTOXNUC",
     :name => "Ontology of Nuclear Toxicity",
     :description => "Traduction française de Ontology of Nuclear Toxicity développée pendant le projet ToxNuc",
     :uploadPath => "#{ontologiesPath}/v2/ONTOTOXNUC.owl"},

    {:acronym => "TOP-MENELAS",
     :name => "Menelas Project Top-Level Ontology",
     :description => "The two main goals MENELAS contributes to are to (i) Provide better account of and better access to medical information through natural languages in order to help physicians in their daily practice, and to (ii) Enhance European cooperation by multilingual access to standardised medical nomenclatures. The major achievements of MENELAS are the realisation of its two functional systems: (i) The Document Indexing System encodes free text PDSs into both an internal representation (a set of Conceptual Graphs) and international nomenclature codes (ICD-9-CM). Instances of the Document Indexing System have been realised for French, English and Dutch ; (ii) The Consultation System allows users to access the information contained in PDSs previously indexed by the Document Indexing System. The test domain for the project was coronary diseases. The existing prototype shows promising results for information retrieval from natural language PDSs and for automatically encoding PDSs into an existing classification such as ICD-9-CM. A set of components, tools, knowledge bases and methods has also been produced by the project. These include language-independent ontology and models for the domain of coronary diseases; conceptual description of the relevant ICD-9-CM codes. This ontology includes a top-ontology, a top-domain ontology and a domain ontology (Coronay diseases surgery). The menelas-top ontology here is the part of the whole ontology without any reference to medical domain. ",
     :uploadPath => "#{ontologiesPath}/v2/TOP-MENELAS.owl"},

    {:acronym => "WHOFRE",
     :name => "OMS Terminologie des Effets Indésirables",
     :description => "Traduction française de WHO Adverse Reaction Terminology (WHO-ART)",
     :uploadPath => "#{ontologiesPath}/v2/WHOFRE.ttl"},

    {:acronym => "CISP2",
     :name => "Classification Internationale des Soins Primaires",
     :description => "Classification Internationale des Soins Primaires, deuxième édition",
     :uploadPath => "#{ontologiesPath}/v2/CISP2.owl"},

    {:acronym => "ICPCFRE",
     :name => "International Classification of Primary Care",
     :description => "International Classification of Primary Care, traduction française, 1993 ",
     :uploadPath => "#{ontologiesPath}/v2/ICPCFRE.ttl"},

    {:acronym => "MEDLINEPLUS",
     :name => "MedlinePlus",
     :description => "MedlinePlus est un site tout public (professionnels, patients, usagers) de la National Library of Medicine (US) proposant de l'information de qualité et concernant la santé. ",
     :uploadPath => "#{ontologiesPath}/v2/MEDLINEPLUS.owl"},

    {:acronym => "SNOMED_INT",
     :name => "Systematized Nomenclature of MEDicine",
     :description => "Systematized Nomenclature of MEDicine, version internationale",
     :uploadPath => "#{ontologiesPath}/v2/SNOMED_INT.owl"},

    {:acronym => "WHO-ART",
     :name => "Adverse Reaction Terminology, version francaise",
     :description => "WHO-ART est une terminologie utilisée pour le codage et l'analyse des données de pharmacovigilance, développée par Uppsala Monitoring Centre, employée aussi bien par les pays membres de l'OMS que dans le monde entier par les compagnies pharmaceutiques et organismes de recherche clinique. Le système terminologique WHO-ART s'applique à coder les effets indésirables des médicaments et elle couvre la plupart des termes médicaux nécessaires dans ce domaine.",
     :uploadPath => "#{ontologiesPath}/v2/WHO-ART.owl"}
]



ontologyUploader = OntologyUploader.new(restUrl, apikey, user, contact, mail)


ontologiesV1.each do |onto|
  puts onto[:acronym]
  puts ontologyUploader.create_ontology(onto[:acronym], onto[:name])
  puts ontologyUploader.upload_submission(onto[:acronym], onto[:description], onto[:uploadPath])
end

=begin
ontologiesV2.each do |onto|
  puts onto[:acronym]
  puts ontologyUploader.upload_submission(onto[:acronym], onto[:description], onto[:uploadPath])
end
=end

# chown -R ncbobp:ncbobp /srv/data/
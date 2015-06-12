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

# The folder where the ontologies are:
ontologiesPath = "/srv/data/ontologies"

# Arrays of hash containing the informations needed to upload the ontologies (acronym, name, description and uploadPath)
# Array for the version 1 ontologies (not corrected)

# Array for the version 2 ontologies (corrected)

#TODO: use a JSON file to generate those hash?

ontologiesV1 = [
    {:acronym => "BHN",
     :name => "Biologie Hors Nomenclature",
     :description => "L'activité innovante de biologie et d'anatomo-pathologie réalisée notamment dans les Centres Hospitalo-Universitaires est habituellement appelée \"activité hors nomenclature\" (BHN pour la biologie hors nomenclature et PHN pour l'anatomo-pathologie hors nomenclature). Ce caractère \"hors nomenclature\" signifie que l'assurance maladie n'a pas encore intégré ces actes dans la Nomenclature des Actes de Biologie Médicale (NABM) ou la Nomenclature Générale des Actes Professionnels (NGAP).",
     :uploadPath => "#{ontologiesPath}/v1/BHN.owl",
     :homepage => "http://wwwold.chu-montpellier.fr/publication/inter_pub/R300/rubrique.jsp",
     :documentation => "",
     :publication => "http://wwwold.chu-montpellier.fr/publication/inter_pub/R300/rubrique.jsp",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"
    },

    {:acronym => "CIF",
     :name => "Classification Internationale du Fonctionnement, du handicap et de la santé",
     :description => "La CIF, élaboré par l'Organisation mondiale de la Santé (OMS) et adoptée par l'Assemblée Mondiale de la Santé en 2001, remplace la Classification Internationale des Handicaps : déficiences, incapacités, désavantages. Cette classification traduit l'évolution internationale des représentations sociales du handicap au cours des trente dernières années. À l'approche traditionnelle du handicap comme caractéristique individuelle ont été opposées des approches sociales du handicap, souvent radicales, interrogeant la place faite aux personnes handicapées dans la société et la discrimination dont elles sont l'objet par défaut d'accessibilité environnementale et d'accès aux droits communs.",
     :uploadPath => "#{ontologiesPath}/v1/CIF.owl",
     :homepage => "http://www.who.int/classifications/icf/en/",
     :documentation => "http://www.who.int/classifications/icf/icfbeginnersguide.pdf",
     :publication => "http://apps.who.int/classifications/icfbrowser/",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"},

    {:acronym => "HRDO",
     :name => "Disease core ontology applied to Rare Diseases",
     :description => "This resource was designed during a PhD in medical informatics (funded by INSERM, 2010-2012). Its components are (i) a core ontology consistent with a metamodel (disorders and groups of disorders, genes, clinical signs and their relations) and (ii) an instantiation of this metamodel with Orphanet Data (available on http://orphadata.org). Research experiments demonstrated (i) efficient classifications generation based on SPARQL Construct, (ii) perspectives in semantic audit of a knowledge base, (iii) semantic comparison with OMIM (www.omim.org) using proximity measurements and (iv) opened perspectives in knowledge sharing (LORD, http://lord.bndmr.fr). Current production services of Orphanet developed ORDO, released in 2014, an ontology synchronized with their production database. This ontology is now available on Bioportal.",
     :uploadPath => "#{ontologiesPath}/v1/HRDO.owl",
     :homepage => "http://xavier-aime.com/ontology/projets-de-recherche/projet-ontoorpha/",
     :documentation => "",
     :publication => "",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"},

    {:acronym => "MEDLINEPLUS",
     :name => "MedlinePlus",
     :description => "MedlinePlus est un site tout public (professionnels, patients, usagers) de la National Library of Medicine (US) proposant de l'information de qualité et concernant la santé. ",
     :uploadPath => "#{ontologiesPath}/v1/MEDLINEPLUS.owl",
     :homepage => "http://www.nlm.nih.gov/medlineplus/",
     :documentation => "",
     :publication => "",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"},

    {:acronym => "SNMIFRE",
     :name => "Systematized Nomenclature of MEDicine",
     :description => "La SNOMED internationale est une nomenclature pluri-axiale couvrant tous les champs de la médecine et de la dentisterie humaines, ainsi que la médecine animale. Il s'agit d'un systême de classification permettant de normaliser l'ensemble des termes médicaux utilisés par les praticiens de santé. La SNOMED a pour fonction d'attribuer un code à chaque concept permettant un grand nombre de combinaisons entre eux. Elle comprend également une liste des diagnostics interfacée avec la CIM-10. La SNOMED permet ainsi de stocker des informations médicales individuelles dans des entrepôts de données afin d'établir des outils d'analyse décisionnelle, de faciliter des décisions thérapeutiques, de contribuer aux études épidémiologiques et à l'enseignement. L'utilisation de SNOMED garantit l'universalité du vocabulaire médical.",
     :uploadPath => "#{ontologiesPath}/v1/SNOMED_int.owl",
     :homepage => "http://www.ihtsdo.org/",
     :documentation => "http://www.nlm.nih.gov/research/umls/sourcereleasedocs/current/SNMI/",
     :publication => "",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"},

    {:acronym => "WHO-ARTFRE",
     :name => "Adverse Reaction Terminology, version francaise",
     :description => "WHO-ART est une terminologie utilisée pour le codage et l'analyse des données de pharmacovigilance, développée par Uppsala Monitoring Centre, employée aussi bien par les pays membres de l'OMS que dans le monde entier par les compagnies pharmaceutiques et organismes de recherche clinique. Le système terminologique WHO-ART s'applique à coder les effets indésirables des médicaments et elle couvre la plupart des termes médicaux nécessaires dans ce domaine.",
     :uploadPath => "#{ontologiesPath}/v1/WHO-ART.owl",
     :homepage => "http://www.who-umc.org/",
     :documentation => "http://www.nlm.nih.gov/research/umls/sourcereleasedocs/current/WHO/",
     :publication => "",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"},

    {:acronym => "CISP2",
     :name => "Classification Internationale des Soins Primaires, deuxième édition",
     :description => "La CISP-2 permet de classer et coder trois éléments de la consultation de médecine générale, ou plus généralement de soins primaires. Il s'agit des motifs de rencontre (du point de vue du patient), les appréciations portées par le professionnel de la santé (problèmes de santé diagnostiqués) et les procédures de soins (réalisées ou programmées). Le rapprochement de ces éléments permet de reconstituer des épisodes de soins, ce qui rend la CISP pleinement compatible avec l'orientation par problèmes du dossier médical.",
     :uploadPath => "#{ontologiesPath}/v1/CISP2.owl",
     :homepage => "http://www.who.int/classifications/icd/adaptations/icpc2/en/",
     :documentation => "http://www.ulb.ac.be/esp/wicc/cisp2.html",
     :publication => "http://wwwold.chu-montpellier.fr/publication/inter_pub/R300/rubrique.jsp",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"
    }
]

ontologiesV2 = [
    {:acronym => "BHN",
     :name => "Biologie Hors Nomenclature",
     :description => "L'activité innovante de biologie et d'anatomo-pathologie réalisée notamment dans les Centres Hospitalo-Universitaires est habituellement appelée \"activité hors nomenclature\" (BHN pour la biologie hors nomenclature et PHN pour l'anatomo-pathologie hors nomenclature). Ce caractère \"hors nomenclature\" signifie que l'assurance maladie n'a pas encore intégré ces actes dans la Nomenclature des Actes de Biologie Médicale (NABM) ou la Nomenclature Générale des Actes Professionnels (NGAP).",
     :uploadPath => "#{ontologiesPath}/v2/BHN.owl",
     :homepage => "http://wwwold.chu-montpellier.fr/publication/inter_pub/R300/rubrique.jsp",
     :documentation => "",
     :publication => "http://wwwold.chu-montpellier.fr/publication/inter_pub/R300/rubrique.jsp",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"},

    {:acronym => "CIF",
     :name => "Classification Internationale du Fonctionnement, du handicap et de la santé",
     :description => "La CIF, élaboré par l'Organisation mondiale de la Santé (OMS) et adoptée par l'Assemblée Mondiale de la Santé en 2001, remplace la Classification Internationale des Handicaps : déficiences, incapacités, désavantages. Cette classification traduit l'évolution internationale des représentations sociales du handicap au cours des trente dernières années. À l'approche traditionnelle du handicap comme caractéristique individuelle ont été opposées des approches sociales du handicap, souvent radicales, interrogeant la place faite aux personnes handicapées dans la société et la discrimination dont elles sont l'objet par défaut d'accessibilité environnementale et d'accès aux droits communs.",
     :uploadPath => "#{ontologiesPath}/v2/CIF.owl",
     :homepage => "http://www.who.int/classifications/icf/en/",
     :documentation => "http://www.who.int/classifications/icf/icfbeginnersguide.pdf",
     :publication => "http://apps.who.int/classifications/icfbrowser/",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"},

    {:acronym => "HRDO",
     :name => "Disease core ontology applied to Rare Diseases",
     :description => "This resource was designed during a PhD in medical informatics (funded by INSERM, 2010-2012). Its components are (i) a core ontology consistent with a metamodel (disorders and groups of disorders, genes, clinical signs and their relations) and (ii) an instantiation of this metamodel with Orphanet Data (available on http://orphadata.org). </ br> Research experiments demonstrated (i) efficient classifications generation based on SPARQL Construct, (ii) perspectives in semantic audit of a knowledge base, (iii) semantic comparison with OMIM (www.omim.org) using proximity measurements and (iv) opened perspectives in knowledge sharing (LORD, http://lord.bndmr.fr). Current production services of Orphanet developed ORDO, released in 2014, an ontology synchronized with their production database. This ontology is now available on Bioportal.",
     :uploadPath => "#{ontologiesPath}/v2/HRDO.owl",
     :homepage => "http://xavier-aime.com/ontology/projets-de-recherche/projet-ontoorpha/",
     :documentation => "",
     :publication => "",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"},

    {:acronym => "MEDLINEPLUS",
     :name => "MedlinePlus",
     :description => "MedlinePlus est un site tout public (professionnels, patients, usagers) de la National Library of Medicine (US) proposant de l'information de qualité et concernant la santé. ",
     :uploadPath => "#{ontologiesPath}/v2/MEDLINEPLUS.owl",
     :homepage => "http://www.nlm.nih.gov/medlineplus/",
     :documentation => "",
     :publication => "",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"},

    {:acronym => "SNMIFRE",
     :name => "Systematized Nomenclature of MEDicine",
     :description => "La SNOMED internationale est une nomenclature pluri-axiale couvrant tous les champs de la médecine et de la dentisterie humaines, ainsi que la médecine animale. Il s'agit d'un systême de classification permettant de normaliser l'ensemble des termes médicaux utilisés par les praticiens de santé. La SNOMED a pour fonction d'attribuer un code à chaque concept permettant un grand nombre de combinaisons entre eux. Elle comprend également une liste des diagnostics interfacée avec la CIM-10. La SNOMED permet ainsi de stocker des informations médicales individuelles dans des entrepôts de données afin d'établir des outils d'analyse décisionnelle, de faciliter des décisions thérapeutiques, de contribuer aux études épidémiologiques et à l'enseignement. L'utilisation de SNOMED garantit l'universalité du vocabulaire médical.",
     :uploadPath => "#{ontologiesPath}/v2/SNOMED_int.owl",
     :homepage => "http://www.ihtsdo.org/",
     :documentation => "http://www.nlm.nih.gov/research/umls/sourcereleasedocs/current/SNMI/",
     :publication => "",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"},

    {:acronym => "WHO-ARTFRE",
     :name => "Adverse Reaction Terminology, version francaise",
     :description => "WHO-ART est une terminologie utilisée pour le codage et l'analyse des données de pharmacovigilance, développée par Uppsala Monitoring Centre, employée aussi bien par les pays membres de l'OMS que dans le monde entier par les compagnies pharmaceutiques et organismes de recherche clinique. Le système terminologique WHO-ART s'applique à coder les effets indésirables des médicaments et elle couvre la plupart des termes médicaux nécessaires dans ce domaine.",
     :uploadPath => "#{ontologiesPath}/v2/WHO-ART.owl",
     :homepage => "http://www.who-umc.org/",
     :documentation => "http://www.nlm.nih.gov/research/umls/sourcereleasedocs/current/WHO/",
     :publication => "",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"},

    {:acronym => "CISP2",
     :name => "Classification Internationale des Soins Primaires, deuxième édition",
     :description => "La CISP-2 permet de classer et coder trois éléments de la consultation de médecine générale, ou plus généralement de soins primaires. Il s'agit des motifs de rencontre (du point de vue du patient), les appréciations portées par le professionnel de la santé (problèmes de santé diagnostiqués) et les procédures de soins (réalisées ou programmées). Le rapprochement de ces éléments permet de reconstituer des épisodes de soins, ce qui rend la CISP pleinement compatible avec l'orientation par problèmes du dossier médical.",
     :uploadPath => "#{ontologiesPath}/v2/CISP2.owl",
     :homepage => "http://www.who.int/classifications/icd/adaptations/icpc2/en/",
     :documentation => "http://www.ulb.ac.be/esp/wicc/cisp2.html",
     :publication => "http://wwwold.chu-montpellier.fr/publication/inter_pub/R300/rubrique.jsp",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"
    },

    {:acronym => "MSHFRE",
     :name => "Medical Subject Headings, version francaise",
     :description => "Le MeSH (Medical Subject Headings), thésaurus biomédical de référence, est un outil d'indexation, de catalogage et d'interrogation des bases de données de la NLM (National Library of Medicine, Bethesda, USA), notamment MEDLINE/PubMed. L'Inserm, partenaire français de la NLM depuis 1969, traduit le MeSH à l'intention des utilisateurs francophones en 1986, le met à jour chaque année et présente la version bilingue sur ce site. Depuis 2004, la mise à jour est réalisée en collaboration avec l'Inist-CNRS (Institut de l'information scientifique et technique du CNRS).",
     :uploadPath => "#{ontologiesPath}/v2/MSHFRE.ttl",
     :homepage => "http://mesh.inserm.fr/mesh/",
     :documentation => "",
     :publication => "",
     :contact => "Claudie Hasenfuss",
     :mail => "hasenfus@vjf.inserm.fr"},

    {:acronym => "MDRFRE",
     :name => "Dictionnaire médical pour les activités règlementaires en matière de médicaments",
     :description => "Traduction française de Medical Dictionary for Regulatory Activities Terminology (MedDRA). Son but est de fournir une terminologie médicale internationale standardisée qui peut être utilisé pour les communications réglementaires et pour l'évaluation de données appartenant à des produits médicaux destinés à l'humain. MedDRA est donc utilisé pour l'enregistrement, la documentation et le suivi des produits médicaux tout au long du cycle de développement du médicament (des essais cliniques au suivi après mise sur le marché)",
     :uploadPath => "#{ontologiesPath}/v2/MDRFRE.ttl",
     :homepage => "http://www.meddra.org",
     :documentation => "",
     :publication => "",
     :contact => "Jim Mundell",
     :mail => "mssohelp@ngc.com"},

    {:acronym => "STY",
     :name => "Réseau sémantique UMLS",
     :description => "",
     :uploadPath => "#{ontologiesPath}/v2/umls_semantictypes_2014ab_french.ttl",
     :homepage => "http://www.nlm.nih.gov/pubs/factsheets/umlssemn.html",
     :documentation => "",
     :publication => "Ontologie des types sémantiques",
     :contact => "Vincent Emonet",
     :mail => "vincent.emonet@lirmm.fr"
    }
]




ontologyUploader = OntologyUploader.new(restUrl, apikey, user)


releaseDate = Time.now.strftime("%Y-%m-%d")


ontologiesV1.each do |onto|
  puts onto[:acronym]
  puts ontologyUploader.create_ontology(onto[:acronym], onto[:name])
  puts ontologyUploader.upload_submission(onto[:acronym], onto[:description], onto[:uploadPath], onto[:homepage], onto[:documentation], onto[:publication], releaseDate,onto[:contact],onto[:mail])
end



ontologiesV2.each do |onto|
  puts onto[:acronym]
  if onto[:acronym] == "MDRFRE" || onto[:acronym] == "MSHFRE"
    puts ontologyUploader.create_ontology(onto[:acronym], onto[:name])
  end
  puts ontologyUploader.upload_submission(onto[:acronym], onto[:description], onto[:uploadPath], onto[:homepage], onto[:documentation], onto[:publication], releaseDate,onto[:contact],onto[:mail])
end


# chown -R ncbobp:ncbobp /srv/data/
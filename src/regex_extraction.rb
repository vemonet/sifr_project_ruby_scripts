




# Little script to perform a simple regex extraction (here to extract all BioPortal attributes)




extract_from = <<-eos
      attribute :homepage, enforce: [:list], extractedMetadata: true, metadataMappings: ["foaf:homepage", "cc:attributionURL", "mod:homepage", "doap:blog"] # TODO: change default attribute name ATTENTION NAMESPACE PAS VRAIMENT BON
      attribute :publication, enforce: [:list], extractedMetadata: true, metadataMappings: ["omv:reference", "dct:bibliographicCitation", "foaf:isPrimaryTopicOf", "schema:citation", "cito:isCitedBy", "bibo:isReferencedBy"] # TODO: change default attribute name
      attribute :URI, namespace: :omv #TODO: attention, attribute particulier. Je le récupère proprement via OWLAPI. le définir direct comme ça sans mappings ? Attention, Il a été passé en majuscule
      attribute :naturalLanguage, namespace: :omv, enforce: [:list], extractedMetadata: true, metadataMappings: ["dc:language", "dct:language", "doap:language"]
      attribute :documentation, namespace: :omv, enforce: [:list], extractedMetadata: true, metadataMappings: ["rdfs:seeAlso", "foaf:page", "vann:usageNote", "mod:document", "dcat:landingPage", "doap:wiki"]
      attribute :version, namespace: :omv, extractedMetadata: true, metadataMappings: ["owl:versionInfo", "mod:version", "doap:release"] # TODO: attention c'est déjà géré (mal) par BioPortal (le virer pour faire plus propre)
      attribute :description, namespace: :omv, extractedMetadata: true, metadataMappings: ["rdfs:comment", "dc:description", "dct:description", "doap:description"]
      attribute :status, namespace: :omv, extractedMetadata: true, metadataMappings: ["adms:status"] # Pas de limitation ici, mais seulement 4 possibilité dans l'UI (alpha, beta, production, retired)
      attribute :contact, enforce: [:existence, :contact, :list]  # Careful its special

      attribute :creationDate, namespace: :omv, enforce: [:date_time], default: lambda { |record| DateTime.now } # Attention c'est créé automatiquement ça, quand la submission est créée
      attribute :released, enforce: [:date_time, :existence], extractedMetadata: true, metadataMappings: ["omv:creationDate", "dc:date", "prov:generatedAtTime", "mod:creationDate", "doap:created"]   # date de release de l'ontologie par ses développeurs

      # Complementary omv metadata
      attribute :modificationDate, namespace: :omv, enforce: [:date_time], extractedMetadata: true, metadataMappings: ["dct:modified"]  # Va falloir faire en sorte de pouvoir extraire la date
      attribute :numberOfAxioms, namespace: :omv, enforce: [:integer], extractedMetadata: true, metadataMappings: ["mod:noOfAxioms"]
      attribute :keyClasses, namespace: :omv, enforce: [:uri, :list], extractedMetadata: true, metadataMappings: ["foaf:primaryTopic", "void:exampleResource"]
      attribute :keywords, namespace: :omv, enforce: [:list], extractedMetadata: true, metadataMappings: ["mod:keyword", "dcat:keyword"] # Attention particulier, ça peut être un simple string avec des virgules
      attribute :knownUsage, namespace: :omv, enforce: [:list], extractedMetadata: true
      attribute :notes, namespace: :omv, extractedMetadata: true, metadataMappings: ["adms:versionNotes"]
      attribute :conformsToKnowledgeRepresentationParadigm, namespace: :omv, enforce: [:list], extractedMetadata: true, metadataMappings: ["mod:KnowledgeRepresentationFormalism"]
      attribute :hasContributor, namespace: :omv, enforce: [:list], extractedMetadata: true, metadataMappings: ["dc:contributor", "dct:contributor", "doap:helper"]
      attribute :hasCreator, namespace: :omv, enforce: [:list], extractedMetadata: true, metadataMappings: ["dc:creator", "dct:creator", "foaf:maker", "prov:wasAttributedTo", "doap:maintainer"]
      attribute :designedForOntologyTask, namespace: :omv, enforce: [:list], extractedMetadata: true, metadataMappings: []
      attribute :endorsedBy, namespace: :omv, enforce: [:list], extractedMetadata: true, metadataMappings: ["mod:endorsedBy"]
      attribute :hasDomain, namespace: :omv, enforce: [:list], extractedMetadata: true, metadataMappings: ["dc:subject", "dct:subject", "foaf:topic", "dcat:theme"]
      attribute :hasFormalityLevel, namespace: :omv, extractedMetadata: true, metadataMappings: ["mod:formalityLevel"]
      attribute :hasLicense, namespace: :omv, enforce: [:list], extractedMetadata: true, metadataMappings: ["dc:rights", "dct:license", "cc:license"]
      attribute :hasOntologySyntax, namespace: :omv, extractedMetadata: true, metadataMappings: ["mod:syntax", "dct:format"]
      attribute :isOfType, namespace: :omv, extractedMetadata: true, metadataMappings: ["dc:type", "dct:type"]
      attribute :usedOntologyEngineeringMethodology, namespace: :omv, enforce: [:list], extractedMetadata: true, metadataMappings: ["mod:methodologyUsed", "adms:representationTechnique"]
      attribute :usedOntologyEngineeringTool, namespace: :omv, extractedMetadata: true, metadataMappings: ["mod:toolUsed"]
      attribute :useImports, namespace: :omv, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: ["owl:imports", "door:imports", "void:vocabulary", "voaf:extends", "dct:requires"]
      attribute :hasPriorVersion, namespace: :omv, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: ["owl:priorVersion", "dct:isVersionOf", "door:priorVersion", "prov:wasDerivedFrom", "adms:prev"]
      attribute :isBackwardCompatibleWith, namespace: :omv, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: ["owl:backwardCompatibleWith", "door:backwardCompatibleWith"]
      attribute :isIncompatibleWith, namespace: :omv, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: ["owl:incompatibleWith", "door:owlIncompatibleWith"]
      attribute :numberOfAxioms, namespace: :omv, enforce: [:integer], extractedMetadata: true, metadataMappings: ["mod:noOfAxioms", "void:triples"]

      # New metadata to BioPortal
      attribute :hostedBy, enforce: [:list, :uri]
      attribute :deprecated, namespace: :owl, enforce: [:boolean], extractedMetadata: true, metadataMappings: []
      attribute :csvDump, enforce: [:uri]

      # New metadata from DOOR
      attribute :ontologyRelatedTo, namespace: :door, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: ["dc:relation", "dct:relation", "voaf:reliesOn"]
      attribute :comesFromTheSameDomain, namespace: :door, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: []
      attribute :similarTo, namespace: :door, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: ["voaf:similar"]
      attribute :isAlignedTo, namespace: :door, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: ["voaf:hasEquivalencesWith"]
      attribute :explanationEvolution, namespace: :door, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: ["voaf:specializes", "prov:specializationOf"]
      attribute :hasDisparateModelling, namespace: :door, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: []

      # New metadata from SKOS
      attribute :hiddenLabel, namespace: :skos, extractedMetadata: true, metadataMappings: []

      # New metadata from DC terms
      attribute :coverage, namespace: :dc, extractedMetadata: true, metadataMappings: ["dct:coverage"]
      attribute :publisher, namespace: :dc, extractedMetadata: true, metadataMappings: ["dct:publisher", "adms:schemaAgency"]
      attribute :identifier, namespace: :dc, extractedMetadata: true, metadataMappings: ["dct:identifier", "skos:notation", "adms:identifier"]
      attribute :source, namespace: :dc, enforce: [:list], extractedMetadata: true, metadataMappings: ["dct:source", "prov:wasInfluencedBy"]
      attribute :abstract, namespace: :dct, extractedMetadata: true, metadataMappings: []
      attribute :alternative, namespace: :dct, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: ["skos:altLabel"]
      attribute :hasPart, namespace: :dct, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: []
      attribute :isFormatOf, namespace: :dct, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: []
      attribute :audience, namespace: :dct, extractedMetadata: true, metadataMappings: ["doap:audience"]
      attribute :valid, namespace: :dct, enforce: [:date_time], extractedMetadata: true, metadataMappings: ["prov:invaliatedAtTime", "schema:endDate"]

      # New metadata from VOID
      attribute :sparqlEndpoint, namespace: :void, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: []
      attribute :entities, namespace: :void, enforce: [:integer], extractedMetadata: true, metadataMappings: []
      attribute :dataDump, namespace: :void, enforce: [:uri, :list], extractedMetadata: true, metadataMappings: ["doap:download-mirror"]
      attribute :openSearchDescription, namespace: :void, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: ["doap:service-endpoint"]
      attribute :uriLookupEndpoint, namespace: :void, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: []

      # New metadata from foaf
      attribute :depiction, namespace: :foaf, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: ["doap:screenshots"]
      attribute :logo, namespace: :foaf, enforce: [:uri], extractedMetadata: true, metadataMappings: []
      attribute :fundedBy, namespace: :foaf, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: ["mod:sponsoredBy"]

      # New metadata from MOD
      attribute :competencyQuestion, namespace: :mod, extractedMetadata: true, metadataMappings: []

      # New metadata from VOAF
      attribute :usedBy, namespace: :voaf, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: []  # Range : Ontology
      attribute :metadataVoc, namespace: :voaf, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: ["mod:vocabularyUsed", "adms:supportedSchema"]
      attribute :generalizes, namespace: :voaf, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: [] # Ontology range
      attribute :hasDisjunctionsWith, namespace: :voaf, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: [] # Ontology range
      attribute :toDoList, namespace: :voaf, enforce: [:list], extractedMetadata: true, metadataMappings: []

      # New metadata from VANN
      attribute :example, namespace: :vann, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: []
      attribute :preferredNamespaceUri, namespace: :vann, extractedMetadata: true, metadataMappings: ["void:uriSpace"]
      attribute :preferredNamespacePrefix, namespace: :vann, extractedMetadata: true, metadataMappings: []

      # New metadata from CC
      attribute :morePermissions, namespace: :cc, extractedMetadata: true, metadataMappings: []
      attribute :useGuidelines, namespace: :cc, extractedMetadata: true, metadataMappings: []

      # New metadata from PROV
      attribute :wasGeneratedBy, namespace: :prov, extractedMetadata: true, metadataMappings: []
      attribute :wasInvalidatedBy, namespace: :prov, extractedMetadata: true, metadataMappings: []

      # New metadata from ADMS and DOAP
      attribute :translation, namespace: :adms, enforce: [:list, :uri], extractedMetadata: true, metadataMappings: []
      attribute :repository, namespace: :doap, enforce: [:uri], extractedMetadata: true, metadataMappings: []
eos

attr_array = []
extract_from.each_line do |line|
  regex_get_attr = line.scan(/attribute :(.*?),/)

  if not attr_array.include? regex_get_attr[0]
    if regex_get_attr[0] != nil
      attr_array.push(regex_get_attr[0][0])
    end
  end
end


puts attr_array.to_s




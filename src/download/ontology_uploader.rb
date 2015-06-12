class OntologyUploader

  attr_reader :restUrl, :apikey, :user, :contact, :mail
  #attr_accessor :uploadPath, :format, :views

  def initialize(restUrl, apikey, user)
    # TODO: parse url here?
    @user=user
    @apikey=apikey
    @restUrl=restUrl
  end

  def create_ontology(acronym, name)
    # Create a new ontology

    uri = URI.parse(@restUrl)
    http = Net::HTTP.new(uri.host, uri.port)

    req = Net::HTTP::Put.new("/ontologies/#{acronym}")

    req['Content-Type'] = "application/json"
    req['Authorization'] = "apikey token=#{@apikey}"


    if (acronym == "CISP2")
      # Special treatment for CISP2 that is a private ontology
      req.body = { "acronym": acronym, "name": name, "administeredBy": [@user], "viewingRestriction": "private", "acl": ["admin"]}.to_json
    else
      req.body = { "acronym": acronym, "name": name, "administeredBy": [@user]}.to_json
    end

    response = http.start do |http|
      http.request(req)
    end

    return response

  end


  def upload_submission(acronym, description, uploadPath, homepage, documentation, publication, released, contact, mail)
    # Add a submission from a local file
    #TODO: Ajouter contact, homepage... (créer contact via REST API)

    uri = URI.parse(@restUrl)
    http = Net::HTTP.new(uri.host, uri.port)

    req = Net::HTTP::Post.new("/ontologies/#{acronym}/submissions")

    req['Content-Type'] = "application/json"
    req['Authorization'] = "apikey token=#{@apikey}"

    # hasOntologyLanguage: OWL, UMLS, SKOS, OBO
    # status: alpha, beta, production, retired
    req.body = {
        "contact": [{"name": contact,"email": mail}],
        "ontology": "#{@restUrl}/ontologies/#{acronym}",
        "hasOntologyLanguage": "OWL",
        "released": released,
        "description": description,
        "status": "production",
        "homepage": homepage,
        "documentation": documentation,
        "publication": publication,
        "naturalLanguage": "fr",
        "uploadFilePath": uploadPath
    }.to_json

    response = http.start do |http|
      http.request(req)
    end

    return response

  end


end
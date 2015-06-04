class OntologyUploader

  attr_reader :restUrl, :apikey, :user, :contact, :mail
  #attr_accessor :uploadPath, :format, :views

  def initialize(restUrl, apikey, user, contact, mail)
    # TODO: parse url here
    @user=user
    @apikey=apikey
    @restUrl=restUrl
    @contact = contact
    @mail=mail
  end

  def create_ontology(acronym, name)
    # Create a new ontology

    uri = URI.parse(@restUrl)
    http = Net::HTTP.new(uri.host, uri.port)

    req = Net::HTTP::Put.new("/ontologies/#{acronym}")

    req['Content-Type'] = "application/json"
    req['Authorization'] = "apikey token=#{@apikey}"

    req.body = { "acronym": acronym, "name": name, "administeredBy": [@user]}.to_json

    response = http.start do |http|
      http.request(req)
    end

    return response

  end


  def upload_submission(acronym, description, uploadPath)
    # Add a submission from a local file  

    uri = URI.parse(@restUrl)
    http = Net::HTTP.new(uri.host, uri.port)

    req = Net::HTTP::Post.new("/ontologies/#{acronym}/submissions")

    req['Content-Type'] = "application/json"
    req['Authorization'] = "apikey token=#{@apikey}"

    # hasOntologyLanguage: OWL, UMLS, SKOS, OBO
    # status: alpha, beta, production, retired
    req.body = {
        "contact": [{"name": @contact,"email": @mail}],
        "ontology": "#{@restUrl}/ontologies/#{acronym}",
        "hasOntologyLanguage": "OWL",
        "released": "2013-01-01T16:40:48-08:00",
        "description": description,
        "status": "production",
        "naturalLanguage": "fr",
        "filePath": uploadPath
    }.to_json

    #"pullLocation": "https://web.archive.org/web/20111213110713/http://www.movieontology.org/2010/01/movieontology.owl"

    #response = http.request(req)
    response = http.start do |http|
      http.request(req)
    end

    return response

  end


end
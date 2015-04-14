class BioPortalOntology

  attr_reader :acronym
  attr_accessor :ddl_url, :format, :views

  def initialize(acronym)
    @acronym=acronym
  end

end
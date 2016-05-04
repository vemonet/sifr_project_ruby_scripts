

def sifr_apikey
  ''
end

def ncbo_apikey
  ''
end

def agroportal_apikey
  ''
end

def stageportal_apikey
  ''
end

def vm_apikey
  ''
end



# Variables for Google Analytics

def analytics_service_account_email_address(portal)
  if portal.eql?("stageportal")
    ""
  elsif portal.eql?("agroportal")
    ""
  elsif portal.eql?("bioportal")
    ""
  end
end

def analytics_path_to_key_file(portal)
  if portal.eql?("stageportal")
    "#{__dir__}/stageportal-#########.p12"
  elsif portal.eql?("agroportal")
    "#{__dir__}/agroportal-########.p12"
  elsif portal.eql?("bioportal")
    "#{__dir__}/bioportal-#########.p12"
  end
end

def analytics_profile_id(portal)
  if portal.eql?("stageportal")
    "ga:#########"
  elsif portal.eql?("agroportal")
    "ga:#######"
  elsif portal.eql?("bioportal")
    "ga:#######"
  end
end

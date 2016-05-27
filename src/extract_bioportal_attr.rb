


# Open a ncbo_cron console (bin/ncbo_cron --console) and execute it

json_all_attr = []

# go through all OntologySubmission attributes. Returns symbols
LinkedData::Models::OntologySubmission.attributes(:all).each do |attr|
  # for attribute with the :extractedMetadata setting on and that have not been defined by the user
  if LinkedData::Models::OntologySubmission.attribute_settings(attr)[:extractedMetadata]
    attr_params = []

    if (LinkedData::Models::OntologySubmission.attribute_settings(attr)[:enforce].include?(:list))
      attr_params.push("list")
    end

    if (LinkedData::Models::OntologySubmission.attribute_settings(attr)[:enforce].include?(:integer))
      attr_params.push("integer")
    end

    if (LinkedData::Models::OntologySubmission.attribute_settings(attr)[:enforce].include?(:uri))
      attr_params.push("uri")
    end

    if (LinkedData::Models::OntologySubmission.attribute_settings(attr)[:enforce].include?(:date_time))
      attr_params.push("date_time")
    end

    if (LinkedData::Models::OntologySubmission.attribute_settings(attr)[:enforce].include?(:boolean))
      attr_params.push("boolean")
    end

    json_single_attr = {}
    json_single_attr["attribute"] = attr.to_s
    json_single_attr["params"] = attr_params

    json_all_attr.push(json_single_attr)
  end
end


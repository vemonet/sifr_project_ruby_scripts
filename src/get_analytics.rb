
require 'logger'
require 'google/api_client'
require 'google/api_client/auth/installed_app'
require_relative '../config.rb'


# Gets Google analytics variables from config file
@analytics_app_name = "stageportal"
#@analytics_app_name = "bioportal"
#@analytics_app_name = "agroportal"

@analytics_service_account_email_address = analytics_service_account_email_address(@analytics_app_name)
@analytics_path_to_key_file = analytics_path_to_key_file(@analytics_app_name)
@analytics_profile_id = analytics_profile_id(@analytics_app_name)


@analytics_app_version                   = "1.0.0"
@analytics_start_date                    = "2015-12-01"
@analytics_filter_str                    = ""

@logger = Logger.new(STDOUT)



def authenticate_google
  client = Google::APIClient.new(
      :application_name => @analytics_app_name,
      :application_version => @analytics_app_version
  )
  key = Google::APIClient::KeyUtils.load_from_pkcs12(@analytics_path_to_key_file, 'notasecret')
  client.authorization = Signet::OAuth2::Client.new(
      :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
      :audience => 'https://accounts.google.com/o/oauth2/token',
      :scope => 'https://www.googleapis.com/auth/analytics.readonly',
      :issuer => @analytics_service_account_email_address,
      :signing_key => key
  )
  client.authorization.fetch_access_token!
  client
end

def fetch_ontology_analytics
  google_client = authenticate_google
  api_method = google_client.discovered_api('analytics', 'v3').data.ga.get
  aggregated_results = Hash.new
  start_year = Date.parse(@analytics_start_date).year || 2013
  #ont_acronyms = LinkedData::Models::Ontology.where.include(:acronym).all.map {|o| o.acronym}
  ont_acronyms = ["STY", "MDRFRE"]

  ont_acronyms.each do |acronym|
    max_results = 10000
    num_results = 10000
    start_index = 1
    results = nil

    loop do
      results = google_client.execute(:api_method => api_method, :parameters => {
          'ids'         => @analytics_profile_id,
          'start-date'  => @analytics_start_date,
          'end-date'    => Date.today.to_s,
          'dimensions'  => 'ga:pagePath,ga:year,ga:month',
          'metrics'     => 'ga:pageviews',
          #'filters'     => "ga:pagePath=~^(\\/ontologies\\/#{acronym})(\\/?\\?{0}|\\/?\\?{1}.*)$;#{@analytics_filter_str}",
          'filters'     => "ga:pagePath=~^(\\/ontologies\\/#{acronym})(\\/?\\?{0}|\\/?\\?{1}.*)$",
          'start-index' => start_index,
          'max-results' => max_results
      })
      start_index += max_results
      num_results = results.data.rows.length
      @logger.info "Acronym: #{acronym}, Results: #{num_results}, Start Index: #{start_index}"

      results.data.rows.each do |row|
        if (aggregated_results.has_key?(acronym))
          # year
          if (aggregated_results[acronym].has_key?(row[1].to_i))
            # month
            if (aggregated_results[acronym][row[1].to_i].has_key?(row[2].to_i))
              aggregated_results[acronym][row[1].to_i][row[2].to_i] += row[3].to_i
            else
              aggregated_results[acronym][row[1].to_i][row[2].to_i] = row[3].to_i
            end
          else
            aggregated_results[acronym][row[1].to_i] = Hash.new
            aggregated_results[acronym][row[1].to_i][row[2].to_i] = row[3].to_i
          end
        else
          aggregated_results[acronym] = Hash.new
          aggregated_results[acronym][row[1].to_i] = Hash.new
          aggregated_results[acronym][row[1].to_i][row[2].to_i] = row[3].to_i
        end
      end

      if (num_results < max_results)
        # fill up non existent years
        (start_year..Date.today.year).each do |y|
          aggregated_results[acronym] = Hash.new if aggregated_results[acronym].nil?
          aggregated_results[acronym][y] = Hash.new unless aggregated_results[acronym].has_key?(y)
        end
        # fill up non existent months with zeros
        (1..12).each { |n| aggregated_results[acronym].values.each { |v| v[n] = 0 unless v.has_key?(n) } }
        break
      end
    end
  end

  @logger.info "Completed ontology analytics refresh..."

  aggregated_results
end

puts @analytics_app_name

puts fetch_ontology_analytics
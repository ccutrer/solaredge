require 'json'
require 'net/http'

require 'openssl'

require 'solar_edge/sites'

module SolarEdge
  class Client
    def initialize(api_key)
      @api_key = api_key
      @host = URI.parse('https://monitoringapi.solaredge.com/')
      @http = Net::HTTP.new(@host.host, @host.port)
      @http.use_ssl = (@host.scheme == 'https')
      @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    def sites(search_text: nil, sort_by: nil, sort_order: nil)
      raise ArgumentError, "invalid sort_by" if sort_by && !VALID_SORT_PROPERTIES.include?(sort_by)
      raise ArgumentError, "sort_order must be specific with sort_by" if sort_order && !sort_by
      raise ArgumentError, "sort_order must be :asc or :desc" if sort_order && !%i{asc desc}.include?(sort_order)

      params = {}
      params[:search_text] = search_text if search_text
      params[:sort_property] = sort_by if sort_by
      params[:sort_order] = sort_order if sort_order

      # we cache the "all sites" query
      if params.empty?
        @sites ||= Sites.new(self, params)
      else
        Sites.new(self, params)
      end
    end

    private

    VALID_SORT_PROPERTIES = %i{
      Name
      Country
      State
      City
      Address
      Zip
      Status
      PeakPower
      InstallationDate
      Amount
      MaxSeverity
      CreationTime
    }.freeze
    private_constant :VALID_SORT_PROPERTIES

    def query(path, params = {})
      params = params.merge(api_key: @api_key)

      uri = @host.merge(path)
      uri.query = self.class.hash_to_query(params)

      get = Net::HTTP::Get.new(uri)
      response = @http.request(get)
      response.body
      JSON.load(response.body)
    end

    def self.hash_to_query(hash)
      hash.map{|k,v| "#{k}=#{v}" }.join("&")
    end
  end
end
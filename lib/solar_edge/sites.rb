require 'solar_edge/site'

module SolarEdge
  class Sites
    include Enumerable

    def initialize(client, params)
      @client, @params = client, params
    end

    def find(id)
      Site.new(client, id)
    end

    def size
      params = @params.dup
      params[:size] = 1
      @client.send(:query, '/sites/list', params)['sites']['count']
    end

    def each
      params = @params.dup
      params[:size] = 100
      params[:startIndex] = 0
      while true
        sites = @client.send(:query, '/sites/list', params)['sites']
        sites['site'].each do |site|
          yield Site.new(@client, site)
        end
        break if sites['site'].length < params[:size] ||
            params[:startIndex] + sites['site'].length == sites['count']
        params[:startIndex] += sites['site'].length
      end
    end
  end
end

require 'active_support/time'

require 'solar_edge/inverter'

module SolarEdge
  class Site
    attr_reader :id

    def initialize(client, id_or_details)
      @client = client
      if id_or_details.is_a?(Hash)
        @details = id_or_details
        @id = @details['id']
      else
        @id = id
      end
    end

    def time_zone
      @time_zone ||= ActiveSupport::TimeZone.new(details['location']['timeZone'])
    end

    def data_period
      response = @client.send(:query, "/site/#{id}/dataPeriod")['dataPeriod']
      time_zone.parse(response['startDate'])..time_zone.parse(response['endDate'])
    end

    def energy(resolution: :quarter_of_an_hour, start_date: time_zone.now, end_date: time_zone.now)
      raise ArgumentError, "invalid resolution" unless %i{quarter_of_an_hour hour day week month year}.include?(resolution)
      params = {}
      params[:timeUnit] = resolution.to_s.upcase
      params[:startDate] = start_date.to_date
      params[:endDate] = end_date.to_date

      @client.send(:query, "/site/#{id}/energy", params)['energy']['values'].map do |value|
        {
          timestamp: time_zone.parse(value['date']),
          value: value['value']
        }
      end
    end

    def power(start_time: time_zone.now.beginning_of_day, end_time: time_zone.now)
      params = {}
      params[:startTime] = start_time.in_time_zone(time_zone).strftime('%Y-%m-%d %H:%M:%S')
      params[:endTime] = end_time.in_time_zone(time_zone).strftime('%Y-%m-%d %H:%M:%S')

      @client.send(:query, "/site/#{id}/power", params)['power']['values'].map do |value|
        {
            timestamp: time_zone.parse(value['date']),
            value: value['value']
        }
      end
    end

    def inverters
      @inverters ||= @client.send(:query, "/equipment/#{id}/list")['reporters']['list'].map do |inverter|
        Inverter.new(self,
                     inverter['name'],
                     inverter['manufacturer'],
                     inverter['model'],
                     inverter['serialNumber'])
      end
    end
    private

    def details
      @details ||= @client.send(:query, "/site/#{id}/details")
    end
  end
end

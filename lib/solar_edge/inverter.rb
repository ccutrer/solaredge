module SolarEdge
  class Inverter
    attr_reader :name, :manufacturer, :model, :serial_number

    def initialize(site, name, manufacturer, model, serial_number)
      @site, @name, @manufacturer, @model, @serial_number = site, name, manufacturer, model, serial_number
    end

    def data(start_time: @site.time_zone.now.beginning_of_day, end_time: @site.time_zone.now)
      params = {}
      params[:startTime] = start_time.in_time_zone(@site.time_zone).strftime('%Y-%m-%d %H:%M:%S')
      params[:endTime] = end_time.in_time_zone(@site.time_zone).strftime('%Y-%m-%d %H:%M:%S')

      @site.instance_variable_get(:@client).send(:query,
        "/equipment/#{@site.id}/#{serial_number}/data", params)['data']['telemetries'].map do |value|
        {
            timestamp: @site.time_zone.parse(value['date']),
            total_active_power: value['totalActivePower'],
            dc_voltage: value['dcVoltage'],
            ground_fault_resistance: value['groundFaultResistance'],
            total_energy: value['totalEnergy'],
            temperature: value['temperature'],
            inverter_mode: value['inverterMode'].to_sym
        }
      end
    end

    def inspect
      "#<SolarEdge::Inverter:#{serial_number} #{manufacturer} #{model} - #{name}>"
    end
  end
end

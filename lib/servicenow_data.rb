require 'net/http'
require 'ostruct'
class ServiceNowData

  def initialize(identifier)
    if /INC\d{7,10}/.match(identifier)
      @lookup_path = "#{ENV['SNOW_PROXY']}/incidents/#{identifier}"
      @type = :incident
    elsif /CHG\d{7,10}/.match(identifier)
      @lookup_path = "#{ENV['SNOW_PROXY']}/changes/#{identifier}"
      @type = :change
    end
  end

  def get_data
    uri = URI(@lookup_path)
    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      parsed = JSON.parse(res.body)
      result = parsed['Data']['result'].first
      r = OpenStruct.new(result)
      r.duration = duration_in_minutes(r) if @type == :change
      return r
    else
      raise("Could not retrieve details for #{@type.to_s.capitalize}")
    end

  end

  def duration_in_minutes(data)
    et = DateTime.parse(data['end_date'])
    st = DateTime.parse(data['start_date'])
    duration = ((et - st) * 24 * 60).to_i
    return duration
  end

end
require 'oauth2'
require 'microsoft_graph'
require 'nokogiri'
require 'net/http'
require_relative 'graph_auth'
require_relative 'email'
require_relative 'servicenow_data'

class GraphAPI
  def initialize(token)
    callback = Proc.new do |r|
      r.headers['Authorization'] = "Bearer #{token}"
    end

    @client = MicrosoftGraph.new(base_url: 'https://graph.microsoft.com/v1.0',
                       cached_metadata_file: File.join(MicrosoftGraph::CACHED_METADATA_DIRECTORY, 'metadata_v1.0.xml'),
                       &callback)
  end

  def whoami
    return @client.me
  end

  def get_user(email)
    return @client.users.find(email)
  end

  def email(req_type,identifier)
    type = Email::Message.email_type_mapper(req_type.to_sym)
    data = ServiceNowData.new(identifier).get_data
    message = Email::Message.new(type,data).message
    return {success: "Message sent #{@client.me.send_mail(message)}"}
  rescue => e
    return {error: "could not complete operation #{e}"}
  end




end

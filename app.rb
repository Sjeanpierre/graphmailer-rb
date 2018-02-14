require 'sinatra'
require 'microsoft_graph'
require_relative 'lib/graph_api'
require_relative 'lib/graph_auth'

set :protection, :except => :json_csrf


set :port, 3000

before do
  content_type 'application/json'
end

get '/'  do
  t = GraphAuth.new
  t.get_token_from_code params[:code]
  redirect '/whoami'
end

get '/whoami' do
  t = GraphAuth.new
  p = GraphAPI.new(t.access_token)
  who = p.whoami
  # {:token_info => t.full_token,:who => who}.to_json
  {:who => who}.to_json
end

get '/:resource/:identifier/:state/notification' do
  t = GraphAuth.new
  p = GraphAPI.new(t.access_token)
  req_type = "#{params[:resource]}_#{params[:state]}"
  res = p.email(req_type,params[:identifier])
  {:result => res.to_h}.to_json
end

get '/auth' do
  t = GraphAuth.new
  redirect t.get_login_url
end
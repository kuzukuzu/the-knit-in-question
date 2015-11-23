require 'sinatra'
require 'sinatra/reloader' if development?
require 'oauth'
require 'twitter'

enable :sessions

CONSUMER_KEY = ENV['CONSUMER_KEY']
CONSUMER_SECRET = ENV['CONSUMER_SECRET']

def oauth_consumer
  OAuth::Consumer.new CONSUMER_KEY, CONSUMER_SECRET, site: 'https://api.twitter.com'
end

before %r{^/(prof-photo)$} do
  if session[:access_token] && session[:access_token_secret]
    @authorized = true

    client = Twitter::REST::Client.new do |config|
      config.consumer_key         = CONSUMER_KEY
      config.consumer_secret      = CONSUMER_SECRET
      config.access_token         = session[:access_token]
      config.access_token_secret  = session[:access_token_secret]
    end

    @prof_photo_url = client.prof_image
  end
end

get '/' do
  slim :index
end

get '/auth' do
  callback_url = "#{request.scheme}://#{request.host}/callback"
  request_token = oauth_consumer.get_request_token(oauth_callback: callback_url)

  session[:request_token] = request_token.token
  session[:request_token_secret] = request_token.secret
  redirect request_token.authorize_url
end

get '/callback' do
  request_token = OAuth::RequestToken.new(oauth_consumer, session[:request_token], session[:request_token_secret])

  access_token = nil
  begin
    access_token = request_token.get_access_token(
      {},
      oauth_token: params[:oauth_token],
      oauth_verifier: params[:oauth_verifier]
    )
  rescue OAuth::Unauthorized
    # TODO make
    raise
  end

  session[:access_token] = access_token.token
  session[:access_token_secret] = access_token.secret

  redirect '/'
end

post '/prof-photo' do
end

# routes for scss / coffee-script
get %r{^/(stylesheets|javascripts)/(.*)\.(css|js)$} do
  dir = params[:captures][0] == 'stylesheets' ? 'scss' : 'coffee'
  file = params[:captures][1]
  method = params[:captures][2] == 'css' ? :scss : :coffee
  send method, :"#{ dir }/#{ file }"
end

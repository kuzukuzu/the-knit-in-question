require 'sinatra'
require 'sinatra/reloader' if development?
require 'oauth'
require 'twitter'

require 'digest/md5'
require 'open-uri'

enable :sessions

CONSUMER_KEY = ENV['CONSUMER_KEY']
CONSUMER_SECRET = ENV['CONSUMER_SECRET']

def oauth_consumer
  OAuth::Consumer.new CONSUMER_KEY, CONSUMER_SECRET, site: 'https://api.twitter.com'
end

before %r{^/(prof-photo)?$} do
  if session[:access_token] && session[:access_token_secret]
    @authorized = true

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key         = CONSUMER_KEY
      config.consumer_secret      = CONSUMER_SECRET
      config.access_token         = session[:access_token]
      config.access_token_secret  = session[:access_token_secret]
    end

    # save profile image to local
    # TODO get default icon?
    @prof_photo_url = '/images/users/' + @client.user.screen_name
    @local_file_path = './public' + @prof_photo_url
    remote_file_url = @client.user.profile_image_uri_https(:original)

    unless File.exist?(@local_file_path)
      IO.copy_stream(open(remote_file_url), @local_file_path)
    end
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
  if params[:apply]
    knit_file_path = './public/images/knit.png'

    prof_photo = Magick::Image.read(@local_file_path).first
    knit = Magick::Image.read(knit_file_path).first

    # 左右反転
    if params[:dir] == -1
      knit.flop!
    end

    # 重ねあわせ
    prof_photo.composite!(knit, params[:left], params[:top], Magick::OverCompositeOp)
    new_prof_photo = prof_photo.to_blob

    @client.update_profile_image(new_prof_photo)
  end

  if params[:reset]
    @client.update_profile_image(File.open(@local_file_path, 'rb').read)
  end
end

# routes for scss / coffee-script
get %r{^/(stylesheets|javascripts)/(.*)\.(css|js)$} do
  dir = params[:captures][0] == 'stylesheets' ? 'scss' : 'coffee'
  file = params[:captures][1]
  method = params[:captures][2] == 'css' ? :scss : :coffee
  send method, :"#{ dir }/#{ file }"
end

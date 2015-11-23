require 'sinatra'
require 'sinatra/reloader' if development?

# require './helpers/html'

get '/' do
  @user = 1
  slim :index
end

post '/prof-photo' do
  @user = 1
  slim :index
end

# routes for scss / coffee-script
get %r{^/(stylesheets|javascripts)/(.*)\.(css|js)$} do
  dir = params[:captures][0] == 'stylesheets' ? 'scss' : 'coffee'
  file = params[:captures][1]
  method = params[:captures][2] == 'css' ? :scss : :coffee
  send method, :"#{ dir }/#{ file }"
end

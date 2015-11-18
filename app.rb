require 'sinatra'
require 'sinatra/reloader' if development?

get '/' do
  '例の帽子 -the knit in question-'
end

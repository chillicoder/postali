require "sinatra"
require "sinatra/reloader" if development?
require "haml"

get "/" do
  @public = settings.port
  @req = request.env

  haml :index
end

get "/q/:code.json" do
  "There is no code #{params[:code]}"
end

get "/stop" do
  halt "WTF!!"
end

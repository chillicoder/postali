require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/redis"
require "haml"
require "json"

get "/" do
  @public = settings.port
  @req = request.env

  haml :index
end

get "/q/:code.json" do
  code = params[:code]

  result = Hash.new

  # inject state
  result[:state] = state(code)

  # municipality
  result[:municipality] = municipality(code)

  # blocks
  result[:blocks] = blocks(code)

  # increment query counter
  redis.incr "#{code}:counter"

  JSON.generate(result)

end

get "/q/:code" do

  @code = params[:code]
  @state = state(@code)
  @municipality = municipality(@code)
  @blocks = blocks(@code)

  haml :show

end

get "/stop" do
  halt "WTF!!"
end

private
def state(code)
  state = Hash.new
  state[:id] = redis.get "#{code}:state:id"
  state[:name] = redis.get "#{code}:state:name"

  return state
end

def municipality(code)
  municipality = Hash.new
  municipality[:id] = redis.get "#{code}:municipality:id"
  municipality[:name] = redis.get "#{code}:municipality:name"

  return municipality
end

def blocks(code)
  redis.smembers "#{code}:blocks"

end


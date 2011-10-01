require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/redis"
require "haml"
require "json"

puts redis.del "foos"
puts redis.rpush "foos", "redis"
puts redis.rpush "foos", "is"
puts redis.rpush "foos", "sweet!"

# 83000 CP
code = {
  :state => { :id => 26, :name => 'Sonora' },
  :municipality => { :id => '030', :name => 'Hermosillo' },
  :blocks => ['Hermosillo Centro', 'Centro Norte', 'Centro Oriente'] # set
}

puts redis.del "83000:blocks"
puts redis.sadd "83000:blocks", "Hermosillo Centro"
puts redis.sadd "83000:blocks", "Centro Norte"
puts redis.sadd "83000:blocks", "Centro Oriente"

puts redis.del "83000:state:id"
puts redis.set "83000:state:id", "26"

puts redis.del "83000:state:name"
puts redis.set "83000:state:name", "Sonora"

puts redis.del "83000:municipality:id"
puts redis.set "83000:municipality:id", "030"

puts redis.del "83000:municipality:name"
puts redis.set "83000:municipality:name", "Hermosillo"

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


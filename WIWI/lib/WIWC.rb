require 'HTTParty'
require 'json'
require 'pp'
class WIW
  include HTTParty
  format :json
  base_uri 'api.wheniwork.com/2'
  headers = { "W-Key" => "9a31294eafbd4d60f16fc2322c447ce7b122a808" }
  res = HTTParty.post("https://api.wheniwork.com/2/login",:body => {:username => 'cmong86@gmail.com',:password => 'Killers1=='}.to_json, headers: {"W-Key" => "9a31294eafbd4d60f16fc2322c447ce7b122a808"})

  headers = {"W-Key" => "9a31294eafbd4d60f16fc2322c447ce7b122a808","W-Token" => JSON.parse(res.body)['token']}
  @@head = headers

  def printHeader()
    @@head
  end

  def shifts
    self.class.get('/shifts', :headers => @@head)
  end

  def users
    self.class.get('/users', :headers => @@head)
  end
  def swaps
    self.class.get('/swaps', :headers => @@head)
  end

end

newWIW = WIW.new()
pp newWIW.swaps

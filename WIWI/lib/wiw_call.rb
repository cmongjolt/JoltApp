require 'HTTParty'
require 'pp'
module WIW
  include HTTParty

  base_uri 'api.wheniwork.com/2/'
  default_params username: 'cmong86@gmail.com', password: 'Killers1==', key:'9a31294eafbd4d60f16fc2322c447ce7b122a808'
  format :json
  headers = { "W-Key" => "9a31294eafbd4d60f16fc2322c447ce7b122a808" }
    res = HTTParty.post(
    "https://api.wheniwork.com/2/login",
    :body => {:username => 'cmong86@gmail.com',
              :password => 'Killers1=='}.to_json,
    headers: {"W-Key" => "9a31294eafbd4d60f16fc2322c447ce7b122a808"}
    )

    w_token = JSON.parse(res.body)['token']

    headers = {
      "W-Key" => "9a31294eafbd4d60f16fc2322c447ce7b122a808",
      "W-Token" => w_token
              }
def self.listShifts
      puts headers 
      shifts = HTTParty.get(
      "https://api.wheniwork.com/2/shifts",
      :headers => headers
      )
      puts shifts

end

end
#WIW.listAccounts
#WhenIWork.listShifts()
#WhenIWork.listRequests()
#WhenIWork.listSwaps()
#WhenIWork.listUsers()
#WhenIWork.listPositions()
#WhenIWork.listAccounts()
#WhenIWork.start

#curl https://api.wheniwork.com/2/login --data '{"username":"cmong86@gmail.com", "password": "Killers1=="}' -H "W-Key: 9a31294eafbd4d60f16fc2322c447ce7b122a808"

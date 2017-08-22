require 'HTTParty'
require 'pp'
module WIW
    include HTTParty

    base_uri 'api.wheniwork.com/2'
#  default_params username: 'peymon@joltdelivery.com', password: 'japnikka123', key:'9a31294eafbd4d60f16fc2322c447ce7b122a808'
    format :json
    headers = { "W-Key" => "9a31294eafbd4d60f16fc2322c447ce7b122a808" }

    res = HTTParty.post("https://api.wheniwork.com/2/login",
    :body => {:username => 'dispatcher@joltdelivery.com',
              :password => 'jolTdriver14'}.to_json,
    :headers => headers
      )
    headers = {
      "W-Key" => "9a31294eafbd4d60f16fc2322c447ce7b122a808",
      "W-Token" => JSON.parse(res.body)['token']
      }

    @@token_head = headers


    def self.listShifts()
        shifts = self.get(
        '/shifts',
        :headers => @@token_head
        )
    end

    def self.routingSwapRequests
        swapData = self.get(
        "https://api.wheniwork.com/2/swaps",
        :headers => @@token_head)

        swapData['swaps'].each do |swap|
        shiftID = swap['shift_id']
        swapID = swap['id']
        shiftDetails = self.get(
        "/shifts/#{shiftID}",
        :headers => @@token_head
        )
        if(self.isCatering(shiftID))
          self.sendCaterEmails(shiftID)
          self.put("https://api.wheniwork.com/2/swaps/#{swapID}/",
          :body => {:status => '4'}.to_json,
          :headers => @@token_head
          )
          self.delete("https://api.wheniwork.com/2/swaps/#{swapID}/",
          :headers => @@token_head
          )
        end

        if(self.isOpen(shiftID))
          self.releaseOCShift(shiftID)
        else
          self.releaseShift(swap)
        end

      end

    end

    def self.releaseOCShift(shiftID)

      shiftDetails = self.get("https://api.wheniwork.com/2/shifts/#{shiftID}",
      :headers => @@token_head)
      self.createShift(shiftDetails)
      self.deleteShift(shiftID)

    end

    def self.releaseShift(swapDetails)
        swapID = swapDetails['id']
        shiftID = swapDetails['shift_id']
        userID = swapDetails['user_id']
        shiftDetails = self.get("https://api.wheniwork.com/2/shifts/#{shiftID}",
        :headers => @@token_head)
        timeFromStart = self.timeBeforeShift(swapID)
        self.driverFeedback(timeFromStart)
        self.createShift(shiftDetails)
        self.deleteShift(shiftID)
    end

    def self.sendCaterEmails(shiftID)
        shiftDetails = self.get(
        "https://api.wheniwork.com/2/shifts/#{shiftID}",
        :headers => @@token_head)

        employeeId = shiftDetails['shift']['user_id']
        userDetails = self.get(
        "https://api.wheniwork.com/2/users/#{employeeId}",
        :headers => @@token_head)

        employeeFirstName = userDetails['user']['first_name']
        employeeLastName =  userDetails['user']['last_name']
        shiftNotes = shiftDetails['shift']['notes']

        emailAccount = "21152167"

        emailDetails = {
          "ids" => emailAccount,
                  "subject" => "Catering Drop Requested",
                  "message" => "#{employeeFirstName} #{employeeLastName} is trying to drop a catering order.\n #{shiftNotes}"
        }.to_json

        self.post(
        "https://api.wheniwork.com/2/send",:body => emailDetails,
        :headers => @@token_head)
    end

    def self.isCatering(shiftID)
      shiftDetails = self.get(
      "https://api.wheniwork.com/2/shifts/#{shiftID}",
      :headers => @@token_head)
      if(shiftDetails['shift']['position_id'] == 1622159 || shiftDetails['shift']['position_id'] == 3722203)
        return true
      else
        return false
      end
    end

    def self.isOpen(shiftID)
      shiftDetails = self.get(
      "https://api.wheniwork.com/2/shifts/#{shiftID}",
      :headers => @@token_head)
      if(shiftDetails['shift']['position_id'] == 1238570)
        return true
      else
        return false
      end
    end

    def self.timeBeforeShift(swapID)
      swapDetails = self.get(
      "/swaps/#{swapID}",
      :headers => @@token_head)

      puts swapStartTime = swapDetails['swap']['created_at']
      shiftID = swapDetails['swap']['shift_id']
      shiftDetails = self.get("/shifts/#{shiftID}",:headers => @@token_head)
      puts shiftStart = shiftDetails['shift']['start_time']
      convertedSwapStart = DateTime.parse swapStartTime
      convertedShiftStart = DateTime.parse shiftStart
      puts convertedShiftStart
      puts convertedSwapStart
      puts time = ((convertedShiftStart.to_time-convertedSwapStart.to_time) / 3600).round(2)
      return time*60
    end

    def self.createShift(shiftDetails)
      shiftID = shiftDetails['shift']['id']

      shift = {
        "location_id" => shiftDetails['shift']['location_id'],
        "position_id" => shiftDetails['shift']['position_id'],
        "site_id"     => shiftDetails['shift']['site_id'],
        "start_time"  => shiftDetails['shift']['start_time'],
        "end_time"    => shiftDetails['shift']['end_time'],
        "color"       => shiftDetails['shift']['color'],
        "notes"       => shiftDetails['shift']['notes'],
      }
      createdShift = self.post(
      "https://api.wheniwork.com/2/shifts/",
      :body => shift.to_json,
      :headers => @@token_head
      )
      createdShiftID = createdShift['shift']['id']
      self.publish(createdShiftID)

    end

    def self.deleteShift(shiftID)
      puts self.delete(
      "https://api.wheniwork.com/2/shifts/#{shiftID}",
      :headers => @@token_head)
    end

    def self.publish(shiftID)
        self.post(
        "https://api.wheniwork.com/2/shifts/publish/#{shiftID}",
        :headers=>@@token_head)
    end

    def self.driverFeedback(timeFromStart)
        if(timeFromStart > 720)
          puts "Shift Change"
        else
          puts "Call Out"
        end
    end

    def self.deleteSwaps
      swapData = self.get(
      "https://api.wheniwork.com/2/swaps",
      :headers => @@token_head)

      swapData['swaps'].each do |swap|
      shiftID = swap['shift_id']
      swapID = swap['id']

      shiftDetails = self.get(
      "/shifts/#{shiftID}",
      :headers => @@token_head
      )
      puts swapID
      shiftID = shiftDetails['id']
      puts "deleting #{shiftID}"
        self.delete("https://api.wheniwork.com/2/swaps/#{swapID}/",
        :headers => @@token_head
        )
      end

    end
end
#Testing stages
WIW.deleteSwaps

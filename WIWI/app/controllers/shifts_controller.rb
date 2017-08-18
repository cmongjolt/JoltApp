class ShiftsController < ApplicationController
  def index
      @shifts = HTTParty.get('https://api.wheniwork.com/2/shifts',
      :headers =>{'Content-Type' => 'application/json'} )
    end
end

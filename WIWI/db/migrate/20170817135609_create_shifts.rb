class CreateShifts < ActiveRecord::Migration[5.1]
  def change
    create_table :shifts do |t|
      t.string :userId
      t.string :positionId
      t.string :startTime
      t.string :endTime
      t.string :notes

      t.timestamps
    end
  end
end

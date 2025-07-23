class UserDevice < ApplicationRecord
  belongs_to :user
  belongs_to :device, foreign_key: :device_serial_number, primary_key: :serial_number
end

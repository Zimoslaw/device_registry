class Device < ApplicationRecord
  has_many :user_devices, foreign_key: :device_serial_number, primary_key: :serial_number
  has_many :users, through: :user_devices
end

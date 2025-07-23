class User < ApplicationRecord
  has_many :api_keys, as: :bearer
  has_many :user_devices
  has_many :devices, through: :user_devices
  has_secure_password
end

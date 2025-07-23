# frozen_string_literal: true

# Error types
module ReturningError

  # User tries to return device from different user
  class Unauthorized < StandardError; end
end

module UnassigningError

  # Device was already returned
  class AlreadyUnassigned < StandardError; end
end

class ReturnDeviceFromUser

  :requesting_user
  :device_owner_id # Device owner
  :serial_number # SN of the device

  def initialize(requesting_user:, serial_number:, from_user:)
    @requesting_user = requesting_user
    @serial_number = serial_number
    @device_owner_id = from_user.to_i
  end

  def call
    # User can't return other's user device
    if @requesting_user.id != @device_owner_id
      raise(ReturningError::Unauthorized)
    end

    # Can't return already returned device
    if UserDevice.exists?(user_id: @device_owner_id, device_serial_number: @serial_number, active: false)
      raise(UnassigningError::AlreadyUnassigned)
    end

    # Changing state of user-device relation to unactive (device is returned)
    UserDevice.where(user_id: @device_owner_id, device_serial_number: @serial_number)
              .update_all(active: false)
  end
end

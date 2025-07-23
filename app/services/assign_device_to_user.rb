# frozen_string_literal: true

# Error types
module RegistrationError

  # User tries to assign device to different user
  class Unauthorized < StandardError; end
end

module AssigningError
  # Device was assigned to user earlier
  class AlreadyUsedOnUser < StandardError; end

  # Device is assigned to another user
  class AlreadyUsedOnOtherUser < StandardError; end
end

class AssignDeviceToUser

  :requesting_user
  :new_device_owner_id # User to assign device to
  :serial_number # Serial number of the device

  def initialize(requesting_user:, serial_number:, new_device_owner_id:)
    @requesting_user = requesting_user
    @serial_number = serial_number
    @new_device_owner_id = new_device_owner_id.to_i
  end

  def call
    # User can't assign device to different user
    if @requesting_user.id != @new_device_owner_id
      raise(RegistrationError::Unauthorized)
    end

    # User can't assign device, that was already assigned to him
    if UserDevice.where(device_serial_number: @serial_number, user_id: @new_device_owner_id).exists?
      raise(AssigningError::AlreadyUsedOnUser)
    end

    # User can't assign device that is assigned to another user
    if UserDevice.exists?(device_serial_number: @serial_number, active: true)
      raise(AssigningError::AlreadyUsedOnOtherUser)
    end

    # Create new device if it doesn't already exist
    device = Device.find_or_create_by!(serial_number: @serial_number)

    # Assign device to user
    # active param tells if user-device relation is active (device is assigned to user) or unactive (device has been returned)
    UserDevice.create!(user_id: @new_device_owner_id, device: device, active: true)

  end
end

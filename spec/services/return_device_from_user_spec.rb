# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReturnDeviceFromUser do
  subject(:return_device) do
    described_class.new(
      requesting_user: user,
      serial_number: serial_number,
      from_user: device_owner_id
    ).call
  end

  let(:user) { create(:user) }
  let(:serial_number) { '123456' }

  context 'when users returns a device from other user' do
    let(:device_owner_id) { create(:user, email: "user1@example.com").id }

    it 'raises an error' do
      expect { return_device }.to raise_error(ReturningError::Unauthorized)
    end
  end

  context 'when user assigns and then returns a device from self' do
    let(:device_owner_id) { user.id }

    it 'device is returned' do
      AssignDeviceToUser.new(requesting_user: user, serial_number: serial_number, new_device_owner_id: device_owner_id).call
      return_device

      expect(user.devices.pluck(:serial_number, :active)).to include([serial_number, 0])
    end
  end

  context 'when a user tries to returned already returned device' do
    let(:device_owner_id) { user.id }

    it 'device is not returned again' do
      AssignDeviceToUser.new(requesting_user: user, serial_number: serial_number, new_device_owner_id: device_owner_id).call
      ReturnDeviceFromUser.new(requesting_user: user, serial_number: serial_number, from_user: device_owner_id).call
      expect { return_device }.to raise_error(UnassigningError::AlreadyUnassigned)
    end
  end
end

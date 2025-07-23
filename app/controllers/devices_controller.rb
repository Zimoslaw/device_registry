# frozen_string_literal: true

class DevicesController < ApplicationController
  before_action :authenticate_user!, only: %i[assign unassign]
  def assign
    AssignDeviceToUser.new(
      requesting_user: @current_user,
      serial_number: params.dig(:device, :serial_number),
      new_device_owner_id: params[:new_owner_id]
    ).call

    head :ok
  rescue RegistrationError::Unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  rescue AssigningError::AlreadyUsedOnUser
    render json: { error: 'This device was previously used by user' }, status: :ok
  rescue AssigningError::AlreadyUsedOnOtherUser
    render json: { error: 'This device is being used by another user' }, status: :ok
  end

  def unassign
    ReturnDeviceFromUser.new(
      requesting_user: @current_user,
      serial_number: params.dig(:device, :serial_number),
      from_user: params[:owner_id]
    ).call

    head :ok
  rescue ReturningError::Unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  rescue UnassigningError::AlreadyUnassigned
    render json: { error: 'This device is already returned' }, status: :ok
  end

  private

  def device_params
    params.permit(:new_owner_id, :serial_number)
  end
end

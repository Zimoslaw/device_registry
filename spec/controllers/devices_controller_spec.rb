# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DevicesController, type: :controller do
  let(:api_key) { create(:api_key) }
  let(:user) { api_key.bearer }

  describe 'POST #assign' do
    subject(:assign) do
      post :assign,
           params: { new_owner_id: new_owner_id, device: { serial_number: '123456' } },
           session: { token: user.api_keys.first.token }
    end
    context 'when the user is authenticated' do
      context 'when user assigns a device to another user' do
        let(:new_owner_id) { create(:user, email: "user1@example.com").id }

        it 'returns an unauthorized response' do
          assign
          expect(response.code).to eq('401')
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
        end
      end

      context 'when user assigns a device to self' do
        let(:new_owner_id) { user.id }

        it 'returns a success response' do
          assign
          expect(response).to be_successful
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized response' do
        post :assign
        expect(response).to be_unauthorized
      end
    end
  end

  describe 'POST #unassign' do
    subject(:unassign) do
      post :unassign,
           params: { owner_id: owner_id, device: { serial_number: '123456' } },
           session: { token: user.api_keys.first.token }
    end

    context 'when the user is authenticated' do
      context 'when user return a device from another user' do
        let(:owner_id) { create(:user, email: "user2@example.com").id }

        it 'returns an unauthorized response' do
          unassign
          expect(response.code).to eq('401')
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
        end
      end

      context 'when user assigns to self and then return a device from self' do
        let(:new_owner_id) { user.id }
        let(:owner_id) { user.id }

        it 'returns a success response' do
          post :assign,
               params: { new_owner_id: owner_id, device: { serial_number: '123456' } },
               session: { token: user.api_keys.first.token }
          unassign
          expect(response).to be_successful
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized response' do
        post :unassign
        expect(response).to be_unauthorized
      end
    end
  end
end

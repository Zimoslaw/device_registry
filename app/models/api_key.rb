# frozen_string_literal: true

class ApiKey < ApplicationRecord
  belongs_to :bearer, polymorphic: true
  has_one :device
end

# frozen_string_literal: true

class HandlerParams
  def initialize(params)
    @params = params
  end

  private

  attr_reader :params
end

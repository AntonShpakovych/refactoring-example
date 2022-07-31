# frozen_string_literal: true

class Card
  include Validations

  attr_accessor :type, :number, :balance

  def initialize(type:, balance:)
    @type = type.to_sym
    @number = create_card_number
    @balance = balance
  end

  def put_tax(amount); end

  def withdraw_tax(amount); end

  private

  def create_card_number
    LENGTH_CARD.times.map { rand(MAX_CARD_DIGIT) }.join
  end
end

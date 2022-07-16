# frozen_string_literal: true

module Validations
  include Constants

  REGULAR_FOR_PASSWORD = /^[a-zA-Z0-9]{#{MIN_PASSWORD_LENGTH},#{MAX_PASSWORD_LENGTH}}$/.freeze
  REGULAR_FOR_LOGIN = /^[a-zA-Z0-9]{4,20}$/.freeze
  REGULAR_FOR_TYPE_CARD = /\A(#{USUAL}||#{CAPITALIST}||#{VIRTUAL})\z/.freeze
  LENGTH_CARD = 16
  MAX_CARD_DIGIT = 10

  def password_valid?(password)
    password.match(REGULAR_FOR_PASSWORD)
  end

  def age_valid?(age)
    age.to_i.between?(23, 90)
  end

  def name_valid?(name)
    !name.empty? && name[0].upcase == name[0]
  end

  def login_valid?(login, all_login)
    login.match(REGULAR_FOR_LOGIN) && !all_login.include?(login)
  end

  def money_valid?(money)
    money.positive?
  end

  def put_money_tax_valid?(money, tax)
    money > tax
  end

  def withdraw_money_tax_valid?(money, card)
    (card.balance - money - card.withdraw_tax(money)).positive?
  end

  def recipient_card_valid?(all_cards, recipient_number)
    all_cards.find { |card| card.number == recipient_number }.nil?
  end

  def recipient_card_length_valid?(recipient_number)
    recipient_number.length == LENGTH_CARD
  end
end

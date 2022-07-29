# frozen_string_literal: true

module Validations
  include Constants

  def password_valid?(password)
    password.match(REGULAR_FOR_PASSWORD)
  end

  def age_valid?(age)
    age.to_i.between?(MIN_AGE, MAX_AGE)
  end

  def name_valid?(name)
    !name.empty? && name.chr.upcase == name.chr
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

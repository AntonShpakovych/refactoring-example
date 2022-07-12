# frozen_string_literal: true

module Validations
  include Constants

  REGULAR_FOR_PASSWORD = /^[a-zA-Z0-9]{#{MIN_PASSWORD_LENGTH},#{MAX_PASSWORD_LENGTH}}$/.freeze
  REGULAR_FOR_LOGIN = /^[a-zA-Z0-9]{4,20}$/.freeze
  REGULAR_FOR_TYPE_CARD = /(#{USUAL}||#{CAPITALIST}||#{VIRTUAL})/.freeze
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

  def create_card_number
    LENGTH_CARD.times.map { rand(MAX_CARD_DIGIT) }.join
  end
end

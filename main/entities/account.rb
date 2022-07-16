# frozen_string_literal: true

class Account
  attr_accessor :login, :name, :card, :password

  def initialize(name, login, password, age, card = [])
    @name  = name
    @login = login
    @password = password
    @age = age
    @card = card
  end

  def add_card(new_card)
    card.push(Card.new(new_card.to_sym))
  end

  def delete_card(card_index)
    card.delete_at(card_index)
  end
end

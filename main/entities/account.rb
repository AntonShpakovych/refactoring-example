# frozen_string_literal: true

class Account
  attr_accessor :login, :name, :cards, :password

  def initialize(name, login, password, age, cards = [])
    @name  = name
    @login = login
    @password = password
    @age = age
    @cards = cards
  end

  def add_card(new_card)
    cards.push(Card.const_get("#{new_card.capitalize}Card").new)
  end

  def delete_card(card_index)
    cards.delete_at(card_index)
  end
end

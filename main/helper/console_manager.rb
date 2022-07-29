# frozen_string_literal: true

module ConsoleManager
  include Validations
  include DataStore

  def choose_account_with_recipient_card(card_recipient)
    accounts.find { |account| account.cards.find { |card| card.number == card_recipient.number } }
  end

  def choose_recipient_card
    recipient_card_number = input(I18n.t('input.recipient_input'))
    all_cards = accounts.map(&:cards).flatten

    return puts I18n.t('wrong.send_money_incorrect_number') unless recipient_card_length_valid?(recipient_card_number)
    return puts I18n.t('wrong.send_money_undefined_card') if recipient_card_valid?(all_cards, recipient_card_number)

    all_cards.find { |card| card.number == recipient_card_number }
  end

  def put_money_input(account, card_index, money = nil)
    card = account.cards[card_index]
    money ||= input(I18n.t('input.put_money')).to_f
    return puts I18n.t('wrong.incorrect_money_input') unless money_valid?(money)

    return puts I18n.t('wrong.tax_higher_than_amount') unless put_money_tax_valid?(money, card.put_tax(money))

    putting_money(card, money)
  end

  def withdraw_input(account, card_index)
    card = account.cards[card_index]
    withdraw = input(I18n.t('input.withdraw_money')).to_f
    return puts I18n.t('wrong.incorrect_withdraw_money_input') unless money_valid?(withdraw)

    return puts I18n.t('wrong.money_not_enough') unless withdraw_money_tax_valid?(withdraw, card)

    withdrawal_money(card, withdraw)
  end

  def send_money_input(current_account, card_number, account_recipient, recipient_card)
    balance_before = current_account.cards[card_number.pred].balance
    withdraw_input(current_account, card_number.pred)
    money = calculate_money_for_send(balance_before, current_account.cards[card_number.pred])
    index_recipient_card = find_recipient_index(account_recipient, recipient_card)
    put_money_input(account_recipient, index_recipient_card, money)
    update_both_account(current_account, account_recipient)
  end

  def calculate_money_for_send(balance_before, card_after)
    (balance_before - card_after.balance) / find_percent_for_card(card_after)
  end

  def find_recipient_index(account, card_recipient)
    account.cards.each_with_index.map { |card, index| index if card.number == card_recipient.number }.first
  end

  def find_percent_for_card(card)
    one_hundred = 1
    case card.type.to_s
    when USUAL then one_hundred + UsualCard::WITHDRAW_TAX_USUAL
    when VIRTUAL then one_hundred + VirtualCard::WITHDRAW_TAX_VIRTUAL
    when CAPITALIST then one_hundred + CapitalistCard::WITHDRAW_TAX_CAPITALIST
    end
  end

  def choose_card(message_info, message_exit, message_wrong)
    puts message_info
    cards = show_cards(with_index: true)
    user_input = input(message_exit)
    return if user_input == EXIT

    return if cards.nil?

    return user_input.to_i if user_input.to_i.between?(1, cards.length)

    puts message_wrong
    choose_card(message_info, message_exit, message_wrong)
  end

  def update_both_account(current_account, account_recipient)
    update_current_account(current_account)
    update_current_account(account_recipient)
  end

  def create_the_first_account
    return create if YES == input(I18n.t('input.create_the_first_account', y: YES, n: NO))

    console
  end

  def putting_money(card, money)
    card.balance = card.balance + money - card.put_tax(money)
    puts I18n.t('input.put_money_result',
                money: money, number: card.number, balance: card.balance, tax: card.put_tax(money))
  end

  def withdrawal_money(card, money)
    card.balance = card.balance - money - card.withdraw_tax(money)
    puts I18n.t('input.withdraw_money_result',
                money: money, number: card.number, balance: card.balance, tax: card.withdraw_tax(money))
  end

  def registration
    name = name_input
    age = age_input
    login = login_input(accounts.map(&:login))
    password = password_input
    [name, login, password, age]
  end

  def sign_in
    [login_input, password_input]
  end

  def puts_cards_account(account, filter)
    return puts I18n.t('wrong.no_active_cards') if account.cards.empty?

    if filter == false
      account.cards.each do |card_item|
        puts "- #{card_item.number}, #{card_item.type}"
      end
    else
      account.cards.each_with_index do |card_item, index|
        puts "- #{card_item.number}, #{card_item.type}, press #{index.next}"
      end
    end
  end
end

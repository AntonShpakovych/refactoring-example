# frozen_string_literal: true

class Console
  include Constants
  include DataStore
  include Validations

  attr_accessor :current_account

  def console
    command = input(welcome)
    case command
    when CREATE then create
    when LOAD then load
    else
      exit
    end
  end

  def create
    name = name_input
    age = age_input
    login = login_input(accounts.map(&:login))
    password = password_input
    @current_account = Account.new(name, login, password, age)
    save_accounts(@current_account)
    main_menu
  end

  def load
    return create_the_first_account unless accounts.any?

    login = login_input
    password = password_input
    unless find_account(login, password)
      puts I18n.t('wrong.account_undefined')
      load
    end
    @current_account = find_account(login, password)
    main_menu
  end

  def main_menu
    command = input(I18n.t('input.main_menu_option',
                           current_account: @current_account.name,
                           SC: SC, CC: CC, DC: DC, PM: PM, WM: WM, SM: SM, DA: DA, EXIT: EXIT))
    command_list(command)
  end

  def command_list(command)
    case command
    when SC then show_cards
    when CC then create_card
    when DC then destroy_card
    when PM then put_money
    when WM then withdraw_money
    when SM then send_money
    when DA then destroy_account
    when EXIT then exit
    else
      puts I18n.t('wrong.wrong_command')
      main_menu
    end
  end

  def show_cards(with_index: false)
    return puts I18n.t('wrong.no_active_cards') if @current_account.card.empty?

    if with_index == false
      @current_account.card.each do |card_item|
        puts "- #{card_item.number}, #{card_item.type}"
      end
    else
      @current_account.card.each_with_index do |card_item, index|
        puts "- #{card_item.number}, #{card_item.type}, press #{index.next}"
      end
    end
  end

  def create_card
    choosed_card = list_card_type
    case choosed_card
    when REGULAR_FOR_TYPE_CARD
      @current_account.add_card(choosed_card)
      update_current_account(@current_account)
    else
      puts I18n.t('wrong.wrong_card_type')
      create_card
    end
  end

  def destroy_card
    return puts I18n.t('wrong.no_active_cards') if @current_account.card.empty?

    card = choose_card(DESTROY_CARD_INFO, DESTROY_CARD_EXIT, DESTROY_CARD_WRONG)
    return if card.nil? || NO == input(I18n.t('destroy_card.are_u_sure',
                                              number: @current_account.card[card.pred].number, y: YES, n: NO))

    @current_account.delete_card(card.pred)
    update_current_account(@current_account)
  end

  def destroy_account
    ask = input(I18n.t('input.destroy_account', y: YES, n: NO))
    return if ask == NO

    delete_account(@current_account)
  end

  def put_money
    card_number = choose_card(PUT_MONEY_INFO, MONEY_EXIT, MONEY_WRONG)
    return if card_number.nil?

    put_money_input(@current_account, card_number.pred)
    update_current_account(@current_account)
  end

  def withdraw_money
    card_number = choose_card(WITHDRAW_MONEY_INFO, MONEY_EXIT, MONEY_WRONG)
    return if card_number.nil?

    withdraw_input(@current_account, card_number.pred)
    update_current_account(@current_account)
  end

  def send_money
    card_number = choose_card(SEND_MONEY_INFO, MONEY_EXIT, MONEY_WRONG)
    return if card_number.nil?

    recipient_card = choose_recipient_card
    return if recipient_card.nil?

    account_recipient = choose_account_with_recipient_card(recipient_card)
    send_money_input(@current_account, card_number, account_recipient, recipient_card)
  end

  private

  def choose_account_with_recipient_card(card_recipient)
    accounts.find { |account| account.card.find { |card| card.number == card_recipient.number } }
  end

  def choose_recipient_card
    recipient_card_number = input('Enter the recipient card:')
    all_cards = accounts.map(&:card).flatten

    return puts I18n.t('wrong.send_money_incorrect_number') unless recipient_card_length_valid?(recipient_card_number)
    return puts I18n.t('wrong.send_money_undefined_card') if recipient_card_valid?(all_cards, recipient_card_number)

    all_cards.find { |card| card.number == recipient_card_number }
  end

  def put_money_input(account, card_index, money = nil)
    card = account.card[card_index]
    money ||= input(I18n.t('input.put_money')).to_f
    return puts I18n.t('wrong.incorrect_money_input') unless money_valid?(money)

    return puts I18n.t('wrong.tax_higher_than_amount') unless put_money_tax_valid?(money, card.put_tax(money))

    putting_money(card, money)
  end

  def withdraw_input(account, card_index)
    card = account.card[card_index]
    withdraw = input(I18n.t('input.withdraw_money')).to_f
    return puts I18n.t('wrong.incorrect_withdraw_money_input') unless money_valid?(withdraw)

    return puts I18n.t('wrong.money_not_enough') unless withdraw_money_tax_valid?(withdraw, card)

    withdrawal_money(card, withdraw)
  end

  def send_money_input(current_account, card_number, account_recipient, recipient_card)
    balance_before = current_account.card[card_number.pred].balance
    withdraw_input(current_account, card_number.pred)
    money = calculate_money_for_send(balance_before, current_account.card[card_number.pred])
    index_recipient_card = find_recipient_index(account_recipient, recipient_card)
    put_money_input(account_recipient, index_recipient_card, money)
    update_both_account(current_account, account_recipient)
  end

  def calculate_money_for_send(balance_before, card_after)
    (balance_before - card_after.balance) / find_percent_for_card(card_after)
  end

  def find_recipient_index(account, card_recipient)
    account.card.each_with_index.map { |card, index| index if card.number == card_recipient.number }.first
  end

  def find_percent_for_card(card)
    one_hundred = 1
    case card.type.to_s
    when USUAL then one_hundred + Card::WITHDRAW_TAX_USUAL
    when VIRTUAL then one_hundred + Card::WITHDRAW_TAX_VIRTUAL
    when CAPITALIST then one_hundred + Card::WITHDRAW_TAX_CAPITALIST
    end
  end

  def choose_card(message_info, message_exit, message_wrong)
    puts(message_info)
    cards = show_cards(with_index: true)
    user_input = input(message_exit)
    return if user_input == EXIT

    return if cards.nil?

    return user_input.to_i if user_input.to_i.between?(1, cards.length)

    puts message_wrong
    choose_card(message_info, message_exit, message_wrong)
  end

  def password_input
    password = input(I18n.t('input.password_input'))
    return password if password_valid?(password)

    puts I18n.t('validations.validation_for_password', min_length: MIN_PASSWORD_LENGTH, max_length: MAX_PASSWORD_LENGTH)
    password_input
  end

  def age_input
    age = input(I18n.t('input.age_input'))
    return age if age_valid?(age)

    puts I18n.t('validations.validation_for_age', min_age: MIN_AGE, max_age: MAX_AGE)
    age_input
  end

  def login_input(check_uniq = '')
    login = input(I18n.t('input.login_input'))
    return login if login_valid?(login, check_uniq)

    puts I18n.t('validations.validation_for_login', min_length: MIN_LOGIN_LENGTH, max_length: MAX_LOGIN_LENGTH)
    login_input
  end

  def name_input
    name = input(I18n.t('input.name_input'))
    return name if name_valid?(name)

    puts I18n.t('validations.validation_for_name')
    name_input
  end

  def welcome
    I18n.t('input.bank_general', bank_name: BANK_NAME, create: CREATE, load: LOAD, exit: EXIT)
  end

  def input(message)
    puts message
    gets.chomp
  end

  def update_both_account(current_account, account_recipient)
    update_current_account(current_account)
    update_current_account(account_recipient)
  end

  def create_the_first_account
    return create if YES == input(I18n.t('input.create_the_first_account', y: YES, n: NO))

    console
  end

  def list_card_type
    input(I18n.t('input.create_card', usual: USUAL, capitalist: CAPITALIST, virtual: VIRTUAL, exit: EXIT))
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
end

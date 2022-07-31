# frozen_string_literal: true

class Console
  include Constants
  include DataStore
  include InputHelper
  include ConsoleManager

  def console
    command = input(I18n.t('input.bank_general', bank_name: BANK_NAME, create: CREATE, load: LOAD, exit: EXIT))
    case command
    when CREATE then create
    when LOAD then load
    else
      exit
    end
  end

  def create
    name, login, password, age = registration
    @current_account = Account.new(name, login, password, age)
    save_accounts(@current_account)
    main_menu
  end

  def load
    return create_the_first_account unless accounts.any?

    login, password = sign_in
    unless find_account(login, password)
      puts I18n.t('wrong.account_undefined')
      load
    end
    @current_account = find_account(login, password)
    main_menu
  end

  def main_menu
    loop do
      command = input(I18n.t('input.main_menu_option',
                             current_account: @current_account.name,
                             SC: SC, CC: CC, DC: DC, PM: PM, WM: WM, SM: SM, DA: DA, EXIT: EXIT))
      break exit if command == EXIT

      command_list(command) if COMMANDS.include?(command)
      puts I18n.t('wrong.wrong_command') unless COMMANDS.include?(command)
    end
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
    end
  end

  def create_card
    choosed_card = input_card_type
    case choosed_card
    when REGULAR_FOR_TYPE_CARD
      @current_account.add_card(choosed_card)
      update_account(@current_account)
    else
      puts I18n.t('wrong.wrong_card_type')
      create_card
    end
  end

  def show_cards(with_index: false)
    puts_cards_account(@current_account, with_index)
  end

  def destroy_card
    card = input_destroy_card
    return if card.nil? || NO == input(I18n.t('destroy_card.are_u_sure',
                                              number: @current_account.cards[card.pred].number, y: YES, n: NO))

    @current_account.delete_card(card.pred)
    update_account(@current_account)
  end

  def destroy_account
    ask = input(I18n.t('input.destroy_account', y: YES, n: NO))
    return if ask == NO

    delete_account(@current_account)
  end

  def put_money
    card_index = input_put_money
    return if card_index.nil?

    put_money_input(@current_account.cards[card_index.pred])
    update_account(@current_account)
  end

  def withdraw_money
    card_index = input_withdraw_money
    return if card_index.nil?

    withdraw_input(@current_account.cards[card_index.pred])
    update_account(@current_account)
  end

  def send_money
    card_index = input_send_money
    recipient_card = choose_recipient_card unless card_index.nil?

    return if card_index.nil? || recipient_card.nil?

    account_recipient, recipient_card_index = choose_account_and_index_recipient(recipient_card)
    card = @current_account.cards[card_index.pred]
    recipient_card = account_recipient.cards[recipient_card_index]
    send_money_input(card, recipient_card)
    update_both_account(@current_account, account_recipient)
  end
end

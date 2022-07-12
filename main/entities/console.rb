# frozen_string_literal: true

class Console
  include Constants
  include DataStore
  include Validations

  def initialize
    @all_accounts = accounts
  end

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
    login = login_input(@all_accounts.map(&:login))
    password = password_input
    @current_account = Account.new(name, login, password, age)
    save_new_account([@current_account])
    main_menu
  end

  def load
    return create_the_first_account unless accounts.any?

    login = login_input
    password = password_input
    @current_account = find_account(login, password)
    unless @current_account
      puts I18n.t('wrong.account_undefined')
      console
    end
    main_menu
  end

  def main_menu
    command = input(I18n.t('input.main_menu_option',
                           current_account: @current_account.name,
                           SC: SC, CC: CC, DC: DC, PM: PM, WM: WM, SM: SM, DA: DA, EXIT: EXIT))
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

  def create_card
    choosed_card = input(I18n.t('input.create_card',
                                usual: USUAL, capitalist: CAPITALIST, virtual: VIRTUAL, exit: EXIT))
    case choosed_card
    when REGULAR_FOR_TYPE_CARD
      update_current_account(@current_account, @current_account.add_card(choosed_card))
    when EXIT then exit
    else
      puts I18n.t('wrong.wrong_card_type')
      create_card
    end
    main_menu
  end

  private

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

  def create_the_first_account
    answer = input(I18n.t('input.create_the_first_account', y: YES, n: NO))
    case answer
    when YES then create
    when NO then console
    else
      puts I18n.t('wrong.wrong_answer', y: YES, n: NO)
      create_the_first_account
    end
  end
end

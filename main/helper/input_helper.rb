# frozen_string_literal: true

module InputHelper
  include Validations

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

  def input_destroy_card
    return puts I18n.t('wrong.no_active_cards') if @current_account.cards.empty?

    choose_card(DESTROY_CARD_INFO, DESTROY_CARD_EXIT, DESTROY_CARD_WRONG)
  end

  def input_put_money
    return puts I18n.t('wrong.no_active_cards') if @current_account.cards.empty?

    choose_card(PUT_MONEY_INFO, MONEY_EXIT, MONEY_WRONG)
  end

  def input_withdraw_money
    return puts I18n.t('wrong.no_active_cards') if @current_account.cards.empty?

    choose_card(WITHDRAW_MONEY_INFO, MONEY_EXIT, MONEY_WRONG)
  end

  def input_card_type
    input(I18n.t('input.create_card', usual: USUAL, capitalist: CAPITALIST, virtual: VIRTUAL, exit: EXIT))
  end

  def input(message)
    puts message
    gets.chomp
  end
end

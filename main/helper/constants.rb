# frozen_string_literal: true

module Constants
  MAX_PASSWORD_LENGTH = 30
  MIN_PASSWORD_LENGTH = 6

  MAX_AGE = 90
  MIN_AGE = 23

  MAX_LOGIN_LENGTH = 20
  MIN_LOGIN_LENGTH = 4

  BANK_NAME = 'RubyG'

  YES = 'yes'
  NO = 'no'
  CREATE = 'create'
  LOAD = 'load'

  SC = 'SC'
  CC = 'CC'
  DC = 'DC'
  PM = 'PM'
  WM = 'WM'
  SM = 'SM'
  DA = 'DA'
  EXIT = 'exit'

  USUAL = 'usual'
  CAPITALIST = 'capitalist'
  VIRTUAL = 'virtual'

  DESTROY_CARD_EXIT = I18n.t('destroy_card.exit', exit: EXIT)
  DESTROY_CARD_INFO = I18n.t('destroy_card.want_to_delete')
  DESTROY_CARD_WRONG = I18n.t('destroy_card.wrong_card')

  PUT_MONEY_INFO = I18n.t('input.put_money_info')
  WITHDRAW_MONEY_INFO = I18n.t('input.withdraw_money_info')
  SEND_MONEY_INFO = I18n.t('input.send_money_info')
  MONEY_EXIT = I18n.t('input.money_exit', exit: EXIT)
  MONEY_WRONG = I18n.t('wrong.money_wrong')
end

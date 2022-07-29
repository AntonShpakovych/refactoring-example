# frozen_string_literal: true

class UsualCard < Card
  BALANCE = 50.00
  TYPE = 'usual'
  PUT_TAX_USUAL = 0.02
  WITHDRAW_TAX_USUAL = 0.05

  def initialize
    super(type: TYPE, balance: BALANCE)
  end

  def put_tax(amount)
    amount * PUT_TAX_USUAL
  end

  def withdraw_tax(amount)
    amount * WITHDRAW_TAX_USUAL
  end
end

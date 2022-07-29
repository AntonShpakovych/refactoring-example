# frozen_string_literal: true

class VirtualCard < Card
  BALANCE = 150.00
  TYPE = 'virtual'
  PUT_TAX_VIRTUAL = 1
  WITHDRAW_TAX_VIRTUAL = 0.88

  def initialize
    super(type: TYPE, balance: BALANCE)
  end

  def put_tax(_)
    PUT_TAX_VIRTUAL
  end

  def withdraw_tax(amount)
    amount * WITHDRAW_TAX_VIRTUAL
  end
end

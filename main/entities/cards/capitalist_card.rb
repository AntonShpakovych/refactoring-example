# frozen_string_literal: true

class CapitalistCard < Card
  BALANCE = 100.00
  TYPE = 'capitalist'
  PUT_TAX_CAPITALIST = 10
  WITHDRAW_TAX_CAPITALIST = 0.04

  def initialize
    super(type: TYPE, balance: BALANCE)
  end

  def put_tax(_)
    PUT_TAX_CAPITALIST
  end

  def withdraw_tax(amount)
    amount * WITHDRAW_TAX_CAPITALIST
  end
end

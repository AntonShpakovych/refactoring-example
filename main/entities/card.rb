# frozen_string_literal: true

class Card
  include Validations

  CARD_TYPE = {
    usual: { type: 'usual', balance: 50.00 },
    capitalist: { type: 'capitalist', balance: 100.00 },
    virtual: { type: 'virtual', balance: 150.00 }
  }.freeze

  def initialize(type)
    @type = type
    @number = create_card_number
    @balance = CARD_TYPE[type][:balance]
  end
end

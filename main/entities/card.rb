# frozen_string_literal: true

class Card
  include Validations

  attr_accessor :type, :number, :balance

  PUT_TAX_CAPITALIST = 10
  PUT_TAX_VIRTUAL = 1
  PUT_TAX_USUAL = 0.02

  WITHDRAW_TAX_CAPITALIST = 0.04
  WITHDRAW_TAX_USUAL = 0.05
  WITHDRAW_TAX_VIRTUAL = 0.88

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

  def put_tax(amount)
    case type
    when USUAL.to_sym then amount * PUT_TAX_USUAL
    when CAPITALIST.to_sym then PUT_TAX_CAPITALIST
    when VIRTUAL.to_sym then PUT_TAX_VIRTUAL
    end
  end

  def withdraw_tax(amount)
    case type
    when USUAL.to_sym then amount * WITHDRAW_TAX_USUAL
    when CAPITALIST.to_sym then amount * WITHDRAW_TAX_CAPITALIST
    when VIRTUAL.to_sym then amount * WITHDRAW_TAX_VIRTUAL
    end
  end

  def self.puts_cards_account(account, filter)
    return puts I18n.t('wrong.no_active_cards') if account.card.empty?

    if filter == false
      account.card.each do |card_item|
        puts "- #{card_item.number}, #{card_item.type}"
      end
    else
      account.card.each_with_index do |card_item, index|
        puts "- #{card_item.number}, #{card_item.type}, press #{index.next}"
      end
    end
  end

  private

  def create_card_number
    LENGTH_CARD.times.map { rand(MAX_CARD_DIGIT) }.join
  end
end

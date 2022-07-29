# frozen_string_literal: true

RSpec.describe Console do
  OVERRIDABLE_FILENAME = 'accounts.yml'

  ASK_PHRASES = {
    name: I18n.t('input.name_input'),
    login: I18n.t('input.login_input'),
    password: I18n.t('input.password_input'),
    age: I18n.t('input.age_input')
  }.freeze

  CARDS = {
    usual: {
      type: :usual,
      balance: 50.00
    },
    capitalist: {
      type: :capitalist,
      balance: 100.00
    },
    virtual: {
      type: :virtual,
      balance: 150.00
    }
  }.freeze

  COMMON_PHRASES = {
    create_first_account: I18n.t('input.create_the_first_account', y: Constants::YES, n: Constants::NO),
    destroy_account: I18n.t('input.destroy_account', y: Constants::YES, n: Constants::NO),
    if_you_want_to_delete: I18n.t('destroy_card.want_to_delete'),
    choose_card: I18n.t('input.put_money_info'),
    choose_card_withdrawing: I18n.t('input.withdraw_money_info'),
    input_amount: I18n.t('input.put_money'),
    withdraw_amount: I18n.t('input.withdraw_money')
  }.freeze

  HELLO_PHRASES = [
    I18n.t('input.bank_general',
           bank_name: Constants::BANK_NAME,
           create: Constants::CREATE,
           load: Constants::LOAD,
           exit: Constants::EXIT)
  ].freeze

  ACCOUNT_VALIDATION_PHRASES = {
    name: I18n.t('validations.validation_for_name'),
    login: I18n.t('validations.validation_for_login',
                  min_length: Constants::MIN_LOGIN_LENGTH, max_length: Constants::MAX_LOGIN_LENGTH),
    password: I18n.t('validations.validation_for_password',
                     min_length: Constants::MIN_PASSWORD_LENGTH,
                     max_length: Constants::MAX_PASSWORD_LENGTH),
    age: I18n.t('validations.validation_for_age', min_age: Constants::MIN_AGE, max_age: Constants::MAX_AGE)
  }.freeze

  ERROR_PHRASES = {
    user_not_exists: I18n.t('wrong.account_undefined'),
    wrong_command: I18n.t('wrong.wrong_command'),
    no_active_cards: I18n.t('wrong.no_active_cards'),
    wrong_card_type: I18n.t('wrong.wrong_card_type'),
    wrong_number: I18n.t('wrong.money_wrong'),
    correct_amount: I18n.t('wrong.incorrect_money_input'),
    tax_higher: I18n.t('wrong.tax_higher_than_amount'),
    correct_amount_with_draw: I18n.t('wrong.incorrect_withdraw_money_input')
  }.freeze

  CREATE_CARD_PHRASES = [I18n.t('input.create_card',
                                usual: Constants::USUAL,
                                virtual: Constants::VIRTUAL,
                                capitalist: Constants::CAPITALIST,
                                exit: Constants::EXIT)].freeze

  let(:current_subject) { described_class.new }

  describe '#console' do
    context 'when correct method calling' do
      after do
        current_subject.console
      end

      it 'create account if input is create' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'create' }
        expect(current_subject).to receive(:create)
      end

      it 'load account if input is load' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'load' }
        expect(current_subject).to receive(:load)
      end

      it 'leave app if input is exit or some another word' do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'another' }
        expect(current_subject).to receive(:exit)
      end
    end

    context 'with correct outout' do
      it do
        allow(current_subject).to receive_message_chain(:gets, :chomp) { 'test' }
        allow(current_subject).to receive(:exit)
        HELLO_PHRASES.each { |phrase| expect(current_subject).to receive(:puts).with(phrase) }
        current_subject.console
      end
    end
  end

  describe '#create' do
    let(:success_name_input) { 'Denis' }
    let(:success_age_input) { '72' }
    let(:success_login_input) { 'Denis' }
    let(:success_password_input) { 'Denis1993' }
    let(:success_inputs) { [success_name_input, success_age_input, success_login_input, success_password_input] }

    context 'with success result' do
      before do
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*success_inputs)
        allow(current_subject).to receive(:main_menu)
        allow(current_subject).to receive(:accounts).and_return([])
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      it 'with correct outout' do
        allow(File).to receive(:open)
        ASK_PHRASES.each_value { |phrase| expect(current_subject).to receive(:puts).with(phrase) }
        ACCOUNT_VALIDATION_PHRASES.values do |phrase|
          expect(current_subject).not_to receive(:puts).with(phrase)
        end
        current_subject.create
      end

      it 'write to file Account instance' do
        current_subject.create
        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        accounts = YAML.load_file(OVERRIDABLE_FILENAME)
        expect(accounts).to be_a Array
        expect(accounts.size).to be 1
        accounts.map { |account| expect(account).to be_a Account }
      end
    end

    context 'with errors' do
      before do
        all_inputs = current_inputs + success_inputs
        allow(File).to receive(:open)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(current_subject).to receive(:main_menu)
        allow(current_subject).to receive(:accounts).and_return([])
      end

      context 'with name errors' do
        context 'without small letter' do
          let(:error_input) { 'some_test_name' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:name] }
          let(:current_inputs) { [error_input, success_age_input, success_login_input, success_password_input] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with login errors' do
        let(:current_inputs) { [success_name_input, success_age_input, error_input, success_password_input] }

        context 'when present' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 3 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 21 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when exists' do
          let(:error_input) { 'Denis1345' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login] }

          before do
            allow(current_subject).to receive(:accounts) { [instance_double(Account, login: error_input)] }
          end

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with age errors' do
        let(:current_inputs) { [success_name_input, error_input, success_login_input, success_password_input] }
        let(:error) { ACCOUNT_VALIDATION_PHRASES[:age] }

        context 'with length minimum' do
          let(:error_input) { '22' }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'with length maximum' do
          let(:error_input) { '91' }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with password errors' do
        let(:current_inputs) { [success_name_input, success_age_input, success_login_input, error_input] }

        context 'when absent' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 5 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 31 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password] }

          it { expect { current_subject.create }.to output(/#{error}/).to_stdout }
        end
      end
    end
  end

  describe '#load' do
    context 'without active accounts' do
      it do
        expect(current_subject).to receive(:accounts).and_return([])
        expect(current_subject).to receive(:create_the_first_account).and_return([])
        current_subject.load
      end
    end

    context 'with active accounts' do
      let(:login) { 'Johnny' }
      let(:password) { 'johnny1' }

      before do
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*all_inputs)
        allow(current_subject).to receive(:accounts) { [instance_double(Account, login: login, password: password)] }
      end

      context 'with correct outout' do
        let(:all_inputs) { [login, password] }

        it do
          expect(current_subject).to receive(:main_menu)
          [ASK_PHRASES[:login], ASK_PHRASES[:password]].each do |phrase|
            expect(current_subject).to receive(:puts).with(phrase)
          end
          current_subject.load
        end
      end

      context 'when account exists' do
        let(:all_inputs) { [login, password] }

        it do
          expect(current_subject).to receive(:main_menu)
          expect { current_subject.load }.not_to output(/#{ERROR_PHRASES[:user_not_exists]}/).to_stdout
        end
      end

      context 'when account doesn\t exists' do
        let(:bad_login) { 'qwess2213' }
        let(:bad_password) { 'qweqwe2s' }
        let(:all_inputs) { [bad_login, bad_password, login, password, 'exit'] }
        let(:message) do
          ASK_PHRASES[:login_input]
          ASK_PHRASES[:password_input]
        end

        it do
          expect(current_subject).to receive(:main_menu).at_least(:once)
          expect { current_subject.load }.to output(/#{I18n.t('wrong.account_undefined')}/).to_stdout
        end
      end
    end
  end

  describe '#create_the_first_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { Constants::YES }
    let(:message) { COMMON_PHRASES[:create_first_account] }

    it 'with correct outout' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) {}
      expect(current_subject).to receive(:console)
      expect { current_subject.create_the_first_account }.to output(message).to_stdout
    end

    it 'calls create if user inputs is y' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) { success_input }
      expect(current_subject).to receive(:create)
      current_subject.create_the_first_account 
    end

    it 'calls console if user inputs is not y' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) { cancel_input }
      expect(current_subject).to receive(:console)
      current_subject.create_the_first_account
    end
  end

  describe '#main_menu' do
    let(:name) { 'John' }
    let(:commands) do
      {
        'SC' => :show_cards,
        'CC' => :create_card,
        'DC' => :destroy_card,
        'PM' => :put_money,
        'WM' => :withdraw_money,
        'SM' => :send_money,
        'DA' => :destroy_account,
        'exit' => :exit
      }
    end

    let(:message) do
      I18n.t('input.main_menu_option',
                  current_account: current_subject.instance_variable_get(:@current_account).name,
                  SC: Constants::SC,
                  CC: Constants::CC,
                  DC: Constants::DC,
                  PM: Constants::PM,
                  WM: Constants::WM,
                  SM: Constants::SM,
                  DA: Constants::DA,
                  EXIT: Constants::EXIT)
    end

    context 'with correct outout' do
      it do
        allow(current_subject).to receive(:show_cards)
        allow(current_subject).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('SC', 'exit')
        current_subject.instance_variable_set(:@current_account, instance_double(Account, name: name))
        expect { current_subject.main_menu }.to output(/#{message}/).to_stdout
      end
    end

    context 'when commands used' do
      let(:undefined_command) { 'undefined' }
      let(:message) do
        ERROR_PHRASES[:wrong_command]
      end

      it 'calls specific methods on predefined commands' do
        current_subject.instance_variable_set(:@current_account, instance_double(Account, name: name))
        allow(current_subject).to receive(:exit)

        commands.each do |command, method_name|
          expect(current_subject).to receive(method_name)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(command, 'exit')
          current_subject.main_menu
        end
      end

      it 'outputs incorrect message on undefined command' do
        current_subject.instance_variable_set(:@current_account, instance_double(Account, name: name))
        expect(current_subject).to receive(:exit)
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(undefined_command, 'exit')
        expect { current_subject.main_menu }.to output(/#{message}/).to_stdout
      end
    end
  end

  describe '#destroy_account' do
    let(:cancel_input) { 'no' }
    let(:success_input) { 'yes' }
    let(:correct_login) { 'test' }
    let(:fake_login) { 'test1' }
    let(:fake_login2) { 'test2' }
    let(:correct_account) { instance_double(Account, login: correct_login) }
    let(:fake_account) { instance_double(Account, login: fake_login) }
    let(:fake_account2) { instance_double(Account, login: fake_login2) }
    let(:accounts) { [correct_account, fake_account, fake_account2] }
    let(:message) do
      rules =  {'/' => '\/',
               '[' => '\[',
               '?' => '\?'
              }
      dont_change_original = COMMON_PHRASES[:destroy_account].dup
      dont_change_original.gsub!('/\w/', rules)
    end

    after do
      File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
    end

    it 'with correct outout' do
      expect(current_subject).to receive_message_chain(:gets, :chomp) { cancel_input }
      expect { current_subject.destroy_account }.to output(/#{message}/).to_stdout
    end

    context 'when deleting' do
      it 'deletes account if user inputs is y' do
        expect(current_subject).to receive_message_chain(:gets, :chomp) { success_input }
        expect(current_subject).to receive(:accounts) { accounts }
        current_subject.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
        current_subject.instance_variable_set(:@current_account, instance_double(Account, login: correct_login))

        current_subject.destroy_account

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
        file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
        expect(file_accounts).to be_a Array
        expect(file_accounts.size).to be 2
      end

      it 'doesnt delete account' do
        expect(current_subject).to receive_message_chain(:gets, :chomp) { cancel_input }

        current_subject.destroy_account
      end
    end
  end

  describe '#show_cards' do
    let(:cards) { [UsualCard.new, CapitalistCard.new] }

    it 'display cards if there are any' do
      current_subject.instance_variable_set(:@current_account, instance_double(Account, cards: cards))
      cards.each { |card| expect(current_subject).to receive(:puts).with("- #{card.number}, #{card.type}") }
      current_subject.show_cards
    end

    it 'outputs error if there are no active cards' do
      current_subject.instance_variable_set(:@current_account, instance_double(Account, cards: []))
      expect(current_subject).to receive(:puts).with(ERROR_PHRASES[:no_active_cards])
      current_subject.show_cards
    end
  end

  describe '#create_card' do
    let(:test_account) { Account.new('Anton', 'Anton43', 'Anton43', 43) }

    context 'with correct outout' do
      it do
        CREATE_CARD_PHRASES.each { |phrase| expect(current_subject).to receive(:puts).with(phrase) }
        current_subject.instance_variable_set(:@current_account, test_account)
        allow(current_subject).to receive(:accounts).and_return([])
        allow(File).to receive(:open)
        expect(current_subject).to receive_message_chain(:gets, :chomp) { 'usual' }
        current_subject.create_card
      end
    end

    context 'when correct card choose' do
      before do
        allow(current_subject).to receive(:accounts) { [test_account] }
        allow(current_subject).to receive(:exit)
        current_subject.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
        current_subject.instance_variable_set(:@current_account, test_account)
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      CARDS.each do |card_type, card_info|
        it "create card with #{card_type} type" do
          expect(current_subject).to receive_message_chain(:gets, :chomp).and_return(card_info[:type])
          current_subject.create_card
          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          expect(file_accounts.first.cards.first.type).to eq card_info[:type]
          expect(file_accounts.first.cards.first.balance).to eq card_info[:balance]
          expect(file_accounts.first.cards.first.number.length).to be 16
        end
      end
    end

    context 'when incorrect card choose' do
      it do
        current_subject.instance_variable_set(:@cards, [])
        current_subject.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
        current_subject.instance_variable_set(:@current_account, test_account)
        allow(File).to receive(:open)
        allow(current_subject).to receive(:accounts).and_return([])
        allow(current_subject).to receive_message_chain(:gets, :chomp).and_return('test', 'usual')

        expect { current_subject.create_card }.to output(/#{ERROR_PHRASES[:wrong_card_type]}/).to_stdout
      end
    end
  end

  describe '#destroy_card' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double(Account, cards: []))
        expect { current_subject.destroy_card }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { UsualCard.new }
      let(:card_two) { VirtualCard.new }
      let(:fake_cards) { [card_one, card_two] }
      let(:test_account) { Account.new('Anton', 'Anton43', 'Anton43', 43) }

      context 'with correct outout' do
        it do
          allow(test_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, test_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.destroy_card }.to output(/#{COMMON_PHRASES[:if_you_want_to_delete]}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { current_subject.destroy_card }.to output(message).to_stdout
          end
          current_subject.destroy_card
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(test_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, test_account)
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.destroy_card
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(test_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, test_account)
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.destroy_card }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:accept_for_deleting) { 'yes' }
        let(:reject_for_deleting) { 'no' }
        let(:deletable_card_number) { 1 }

        before do
          allow(test_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, test_account)
          current_subject.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
          current_subject.instance_variable_set(:@cards, fake_cards)
          allow(current_subject).to receive(:accounts) { [test_account] }
        end

        after do
          File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
        end

        it 'accept deleting' do
          commands = [deletable_card_number, accept_for_deleting]
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
          expect { current_subject.destroy_card }.to change { current_subject.current_account.cards.size }.by(-1)
          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
          expect(file_accounts.first.cards).not_to include(card_one)
        end

        it 'decline deleting' do
          commands = [deletable_card_number, reject_for_deleting]
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
          expect { current_subject.destroy_card }.not_to change(current_subject.current_account.cards, :size)
        end
      end
    end
  end

  describe '#put_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double(Account, cards: []))
        expect { current_subject.put_money }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { UsualCard.new }
      let(:card_two) { VirtualCard.new }
      let(:card_three) { CapitalistCard.new }
      let(:fake_cards) { [card_one, card_two, card_three] }
      let(:test_account) { Account.new('Anton', 'Anton43', 'Anton43', 43) }

      context 'with correct outout' do
        it do
          allow(test_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, test_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.put_money }.to output(/#{COMMON_PHRASES[:choose_card]}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { current_subject.put_money }.to output(message).to_stdout
          end
          current_subject.put_money
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(test_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, test_account)
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.put_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(test_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, test_account)
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.put_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.put_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) { CapitalistCard.new }
        let(:card_two) { UsualCard.new }
        let(:card_three) { VirtualCard.new }
        let(:fake_cards) { [card_one, card_two, card_three] }
        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:correct_money_amount_lower_than_tax) { 5 }
        let(:money) { 25.0 }
        let(:test_account) { Account.new('Anton', 'Anton43', 'Anton43', 43) }

        before do
          test_account.instance_variable_set(:@cards, fake_cards)
          current_subject.instance_variable_set(:@current_account, test_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.put_money }.to output(/#{COMMON_PHRASES[:input_amount]}/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.put_money }.to output(/#{ERROR_PHRASES[:correct_amount]}/).to_stdout
          end
        end

        context 'with amount greater then 0' do
          context 'with tax greater than amount' do
            let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

            it do
              expect { current_subject.put_money }.to output(/#{ERROR_PHRASES[:tax_higher]}/).to_stdout
            end
          end

          context 'with tax lower than amount' do
            let(:commands) { [chosen_card_number, money] }

            def message(money, number, balance, tax)
              I18n.t('input.put_money_result',
                     money: money,
                     number: number,
                     balance: balance + money - tax,
                     tax: tax)
            end

            after do
              File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
            end

            it do
              fake_cards.each do |custom_card|
                allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
                allow(current_subject).to receive(:accounts) { [test_account] }
                test_account.instance_variable_set(:@cards, [custom_card])
                current_subject.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
                expect do
                  current_subject.put_money
                end.to output(
                  /#{message(money, custom_card.number, custom_card.balance, custom_card.put_tax(money))}/
                ).to_stdout
                expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
                file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)
              end
            end
          end
        end
      end
    end
  end

  describe '#withdraw_money' do
    context 'without cards' do
      it 'shows message about not active cards' do
        current_subject.instance_variable_set(:@current_account, instance_double(Account, cards: []))
        expect { current_subject.withdraw_money }.to output(/#{ERROR_PHRASES[:no_active_cards]}/).to_stdout
      end
    end

    context 'with cards' do
      let(:card_one) { UsualCard.new }
      let(:card_two) { VirtualCard.new }
      let(:card_three) { CapitalistCard.new }
      let(:fake_cards) { [card_one, card_two, card_three] }
      let(:test_account) { Account.new('Anton', 'Anton43', 'Anton43', 43) }

      context 'with correct outout' do
        it do
          allow(test_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, test_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          expect { current_subject.withdraw_money }.to output(/#{COMMON_PHRASES[:choose_card_withdrawing]}/).to_stdout
          fake_cards.each_with_index do |card, i|
            message = /- #{card.number}, #{card.type}, press #{i + 1}/
            expect { current_subject.withdraw_money }.to output(message).to_stdout
          end
          current_subject.withdraw_money
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(test_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, test_account)
          expect(current_subject).to receive_message_chain(:gets, :chomp) { 'exit' }
          current_subject.withdraw_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(test_account).to receive(:cards) { fake_cards }
          current_subject.instance_variable_set(:@current_account, test_account)
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(fake_cards.length + 1, 'exit')
          expect { current_subject.withdraw_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end

        it do
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(-1, 'exit')
          expect { current_subject.withdraw_money }.to output(/#{ERROR_PHRASES[:wrong_number]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) { UsualCard.new }
        let(:card_two) { VirtualCard.new }
        let(:card_three) { CapitalistCard.new }
        let(:fake_cards) { [card_one, card_two, card_three] }
        let(:chosen_card_number) { 1 }
        let(:incorrect_money_amount) { -2 }
        let(:test_account) { Account.new('Anton', 'Anton43', 'Anton43', 43) }
        let(:money) { 25.0 }

        before do
          test_account.instance_variable_set(:@cards, fake_cards)
          current_subject.instance_variable_set(:@current_account, test_account)
          allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { current_subject.withdraw_money }.to output(/#{COMMON_PHRASES[:withdraw_amount]}/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }
          let(:message) do
            ERROR_PHRASES[:correct_amount_with_draw].gsub('$', '\$')
          end

          it do
            expect { current_subject.withdraw_money }.to output(/#{message}/).to_stdout
          end
        end

        context 'with amount greater then card balance' do
          let(:amount_greater_then_balance) { 2500 }
          let(:commands) { [chosen_card_number, amount_greater_then_balance] }

          it do
            expect { current_subject.withdraw_money }.to output(/#{ERROR_PHRASES[:not_enough]}/).to_stdout
          end
        end

        context 'with correct money amount' do
          let(:commands) { [chosen_card_number, money] }

          def message(money, number, balance, tax)
            I18n.t('input.withdraw_money_result',
                   money: money,
                   number: number,
                   balance: balance - money - tax,
                   tax: tax).gsub('$', '\$')
          end

          after do
            File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
          end

          it do
            fake_cards.each do |custom_card|
              allow(current_subject).to receive_message_chain(:gets, :chomp).and_return(*commands)
              allow(current_subject).to receive(:accounts) { [test_account] }
              current_subject.instance_variable_set(:@file_path, OVERRIDABLE_FILENAME)
              test_account.instance_variable_set(:@cards, [custom_card])
              expect do
                current_subject.withdraw_money
              end.to output(
                /#{message(money, custom_card.number, custom_card.balance, custom_card.withdraw_tax(money))}/
              ).to_stdout
            end
          end
        end
      end
    end
  end
end

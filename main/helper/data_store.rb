# frozen_string_literal: true

module DataStore
  FILE_PATH = 'accounts.yml'

  def save_new_account(new_account)
    account_for_save = new_account.to_yaml
    account_for_save.slice!('---')
    File.open(FILE_PATH, 'a') { |file| file.write account_for_save }
  end

  def accounts
    if File.exist?('accounts.yml')
      YAML.load_file('accounts.yml')
    else
      []
    end
  end

  def update_current_account(account, add_new_functionality)
    accounts.delete(find_account(account.login, account.password))
    accounts.each { |a| puts a.name }
    # updated_account = add_new_functionality
    # puts updated_account
    # accounts << updated_account
    # File.open(FILE_PATH, 'w') { |file| file.write accounts.to_yaml }
  end

  def find_account(login_find, password_find)
    accounts.find { |account| account.login == login_find && account.password == password_find }
  end
end

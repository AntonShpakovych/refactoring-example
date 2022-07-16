# frozen_string_literal: true

module DataStore
  FILE_PATH = 'accounts.yml'

  def accounts
    if File.exist?('accounts.yml')
      YAML.load_file('accounts.yml')
    else
      []
    end
  end

  def save_accounts(new_account)
    all_accounts = accounts
    all_accounts << new_account
    File.write(FILE_PATH, all_accounts.to_yaml)
  end

  def update_current_account(account_for_update)
    all_accounts = accounts
    all_accounts.delete_if { |account| account.login == account_for_update.login }
    all_accounts << account_for_update
    File.write(FILE_PATH, all_accounts.to_yaml)
  end

  def find_account(login_find, password_find)
    all_accounts = accounts
    all_accounts.find { |account| account.login == login_find && account.password == password_find }
  end

  def delete_account(account_for_delete)
    all_accounts = accounts.reject { |account| account.login == account_for_delete.login }
    File.write(FILE_PATH, all_accounts.to_yaml)
  end
end

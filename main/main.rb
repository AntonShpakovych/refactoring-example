require 'yaml'
require 'i18n'
require_relative 'helper/constants'
require_relative 'helper/validation'
require_relative 'entities/card'
require_relative 'locales/config'
require_relative 'helper/data_store'
require_relative 'entities/console'
require_relative 'entities/account'

Console.new.console

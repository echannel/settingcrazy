require 'rspec/its'

require File.expand_path("../../lib/settingcrazy", __FILE__)
require 'support/templates/example_template'
require 'support/templates'
require 'support/models'
require 'pry'

RSpec.configure do |config|
  config.mock_with :mocha
end

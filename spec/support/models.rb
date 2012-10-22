require 'active_record'
require 'sqlite3'

root = File.expand_path("../../../", __FILE__)
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "#{root}/db/safeattributes.db"
)

Dir["#{root}/spec/support/models/*.rb"].each { |f| require f }

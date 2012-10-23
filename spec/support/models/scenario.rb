ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'scenarios'")
ActiveRecord::Base.connection.create_table(:scenarios) do |t|
  t.string :name
end

class Scenario < ActiveRecord::Base  
  include SettingCrazy
  attr_accessible :name
  setting_namespace :google
  setting_namespace :yahoo
end

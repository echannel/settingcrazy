ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'campaigns'")
ActiveRecord::Base.connection.create_table(:campaigns) do |t|
  t.string :name
  t.references :scenario
end

class Campaign < ActiveRecord::Base  
  include SettingCrazy
  belongs_to :scenario
  attr_accessible :name
  settings_inherit_via :scenario, :namespace => :google
end

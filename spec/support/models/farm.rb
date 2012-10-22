ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'farms'")
ActiveRecord::Base.connection.create_table(:farms) do |t|
  t.string :name
end

class Farm < ActiveRecord::Base  
  include SettingCrazy
  attr_accessible :name
  has_many :ducks
end

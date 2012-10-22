ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'cases'")
ActiveRecord::Base.connection.create_table(:cases) do |t|
  t.string :name
end

class Case < ActiveRecord::Base  
  include SettingCrazy
  use_setting_template ExampleTemplate
  attr_accessible :name
  has_many :notes
end

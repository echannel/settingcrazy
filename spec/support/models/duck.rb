ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'ducks'")
ActiveRecord::Base.connection.create_table(:ducks) do |t|
  t.string :name
  t.integer :quacks
  t.references :farm
end

class Duck < ActiveRecord::Base  
  include SettingCrazy
  belongs_to :farm
  settings_inherit_via :farm
end

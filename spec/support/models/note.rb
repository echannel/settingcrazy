ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'notes'")
ActiveRecord::Base.connection.create_table(:notes) do |t|
  t.string :name
  t.references :case
end

class Note < ActiveRecord::Base  
  include SettingCrazy
  attr_accessor :name
  belongs_to :case
  settings_inherit_via :case
end

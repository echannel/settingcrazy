ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'vendor_instances'")
ActiveRecord::Base.connection.create_table(:vendor_instances) do |t|
  t.string :name
end

class VendorInstance < ActiveRecord::Base
  include SettingCrazy
  attr_accessor :name
end

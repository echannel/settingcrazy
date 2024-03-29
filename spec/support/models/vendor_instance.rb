ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'vendor_instances'")
ActiveRecord::Base.connection.create_table(:vendor_instances) do |t|
  t.string :name
end

class VendorInstance < ActiveRecord::Base
  include SettingCrazy
  setting_namespace :google
end

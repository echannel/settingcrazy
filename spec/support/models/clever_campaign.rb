ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'clever_campaigns'")
ActiveRecord::Base.connection.create_table(:clever_campaigns) do |t|
  t.string :name
  t.string :setting_namespace
  t.references :scenario
end

class CleverCampaign < ActiveRecord::Base
  include SettingCrazy
  belongs_to :scenario
  attr_accessor :name, :setting_namespace
  settings_inherit_via :scenario, :namespace => Proc.new { |clever_campaign| clever_campaign.setting_namespace }
end

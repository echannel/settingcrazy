ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'templated_campaigns'")
ActiveRecord::Base.connection.create_table(:templated_campaigns) do |t|
  t.string     :name
  t.references :scenario
end

class TemplatedCampaign < ActiveRecord::Base
  include SettingCrazy
  attr_accessible :name
  use_setting_template ExampleCampaignTemplate
end

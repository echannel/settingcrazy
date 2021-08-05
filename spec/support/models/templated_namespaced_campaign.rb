ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'templated_namespaced_campaigns'")
ActiveRecord::Base.connection.create_table(:templated_namespaced_campaigns) do |t|
  t.string     :name
  t.references :scenario
end

class TemplatedNamespacedCampaign < ActiveRecord::Base
  include SettingCrazy
  belongs_to :scenario
  use_setting_template ExampleCampaignTemplate
  settings_inherit_via :scenario, namespace: :google
end

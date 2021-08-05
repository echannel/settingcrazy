ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'inherited_templated_scenarios'")
ActiveRecord::Base.connection.create_table(:inherited_templated_scenarios) do |t|
  t.string :name
end

class InheritedTemplatedScenario < ActiveRecord::Base
  include SettingCrazy
  use_setting_template InheritingTemplate
end

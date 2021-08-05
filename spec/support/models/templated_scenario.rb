ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'templated_scenarios'")
ActiveRecord::Base.connection.create_table(:templated_scenarios) do |t|
  t.string :name
end

class TemplatedScenario < ActiveRecord::Base  
  include SettingCrazy
  setting_namespace :google, :template => ExampleTemplate
  setting_namespace :yahoo
end

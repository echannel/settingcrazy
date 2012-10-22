require 'rails'

module Settingcrazy
  module Generators
    class SettingValuesMigrationGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../../../../../lib/generators/settingcrazy/setting_values_migration/templates/', __FILE__)

      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def create_setting_values_migration_file
        migration_template 'migration.rb', 'db/migrate/create_settings_values'
      end
    end
  end
end

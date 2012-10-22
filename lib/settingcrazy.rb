autoload :ActiveRecord, 'active_record'

require "settingcrazy/version"
require "settingcrazy/settings_proxy"
require "settingcrazy/setting_value"
require "settingcrazy/class_methods"

module SettingCrazy
  def self.included(base)
    base.extend ClassMethods
    base.class_eval <<-EVAL
      has_many :setting_values, :class_name => SettingCrazy::SettingValue, :as => :settable, :autosave => true
    EVAL
  end

  def settings
    @settings ||= SettingsProxy.new(self, self.class.setting_template(self))
  end

  def settings=(attributes)
    attributes.each do |(k,v)|
      self.settings[k] = v
    end
  end
end

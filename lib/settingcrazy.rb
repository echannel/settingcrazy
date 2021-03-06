autoload :ActiveRecord, 'active_record'

require "settingcrazy/version"
require "settingcrazy/namespace"
require "settingcrazy/settings_proxy"
require "settingcrazy/namespaced_settings_proxy"
require "settingcrazy/setting_value"
require "settingcrazy/class_methods"
require "settingcrazy/instance_methods"
require "settingcrazy/attribute_methods"
require "settingcrazy/inheritor"
require "settingcrazy/template"
require "settingcrazy/constants"
require "settingcrazy/settings_validator"

module SettingCrazy
  def self.included(base)
    base.class_eval <<-EVAL
      has_many :setting_values, :class_name => "SettingCrazy::SettingValue", :as => :settable, :autosave => true
      validates_with SettingsValidator
      attr_accessor :setting_errors
    EVAL
    base.extend ClassMethods
    base.send(:include, InstanceMethods)
  end
end

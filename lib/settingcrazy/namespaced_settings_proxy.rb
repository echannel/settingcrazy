module SettingCrazy
  class NamespacedSettingsProxy < SettingsProxy
    def initialize(model, namespace)
      @model      = model
      @namespace  = namespace
      @template   = namespace.template
    end

    protected
      def build_value(key, value)
        @model.setting_values.build(:key => key, :value => value, :namespace => @namespace.name)
      end

      def setting_values
        @model.setting_values.namespace(@namespace.name)
      end
  end
end

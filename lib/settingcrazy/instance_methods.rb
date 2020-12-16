
module SettingCrazy
  module InstanceMethods
    def assign_attributes(values)
      if values.has_key?(:settings)
        self.settings = values.delete(:settings)
      end

      super(values)
    end

    def settings
      @settings ||= SettingsProxy.new(self, self.class.setting_template(self))
    end

    def settings=(attributes)
      settings.bulk_assign(attributes)
    end
  end
end


module SettingCrazy
  module InstanceMethods
    def assign_attributes(values, options = {})
      if values.has_key?(:settings)
        self.settings = values.delete(:settings)
      end

      super(values, options)
    end

    def settings
      @settings ||= SettingsProxy.new(self, self.class.setting_template(self))
    end

    def settings=(attributes)
      settings.bulk_assign(attributes)
    end

    def inherited_namespace
      if self.class._inheritor.present?
        self.respond_to?(:setting_namespace) ? self.setting_namespace : self.class._inheritor._parent_namespace
      else

      end
    end
  end
end

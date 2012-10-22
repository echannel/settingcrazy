
module SettingCrazy
  module InstanceMethods
    def assign_attributes(values, options = {})
      if values.has_key?(:settings)
        self.settings = values.delete(:settings)
      end

      super(values, options)
    end
  end
end

module SettingCrazy
  class SettingsProxy
    attr_reader :template

    def initialize(model, template)
      @model = model
      @template = template
    end

    def []=(key, value)
      sv = setting_record(key)
      if sv.blank?
        @model.setting_values.build(:key => key, :value => value)
      else
        # TODO: DOes this save? It shouldn't
        sv.update_attribute(:value, value)
      end
    end

    def [](key)
      sv = setting_record(key)
      if sv.blank?
        parent_value(key) || template_default_value(key) || nil
      else
        sv.value
      end
    end

    def delete(key)
      setting_record(key).try(:destroy)
    end

    def method_missing(method_name, *args, &block)
      if method_name =~ /=$/
        attribute = method_name[0...-1]
        self[attribute] = args.first
      else
        self[method_name]
      end
    end

    def parent_settings
      return nil if @model.class._inherit_via.blank? || @model.send(@model.class._inherit_via).blank?
      # TODO: Check for settings_groups!? And only use the same template
      @model.send(@model.class._inherit_via).settings
    end
    
    def each(&block)
      @model.setting_values.each(&block)
    end

    def map(&block)
      @model.setting_values.map(&block)
    end

    def inspect
      @model.setting_values.inject({}) do |hash, sv|
        hash[sv.key] = sv.value
        hash
      end.inspect
    end

    private
      def template_default_value(key)
        template.present? ? template.defaults[key] : nil
      end

      def parent_value(key)
        parent_settings.present? ? parent_settings[key] : nil
      end

      def setting_record(attribute)
        # Check valid template attrs
        if template.present? && !template.valid_option?(attribute)
          raise ActiveRecord::UnknownAttributeError
        end
        # TODO: How do we handle many values??
        @model.setting_values.where(:key => attribute).first
      end
  end
end

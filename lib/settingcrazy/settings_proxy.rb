module SettingCrazy
  class SettingsProxy
    attr_reader :template

    def initialize(model, template)
      @model      = model
      @template   = template
      @namespaces = model.class._setting_namespaces
      # TODO: It would probably be a good idea to memoize the NamespacedSettingsProxies
    end

    def []=(key, value)
      if @namespaces && namespace = @namespaces[key.to_sym]
        return NamespacedSettingsProxy.new(@model, namespace).bulk_assign(value)
      end

      value.reject!(&:blank?) if value.respond_to?(:reject!)
      sv = setting_record(key)
      if sv.blank?
        build_value(key, value)
      else
        sv.value = value
      end
    end

    def [](key)
      if @namespaces && namespace = @namespaces[key.to_sym]
        return NamespacedSettingsProxy.new(@model, namespace)
      end
      sv = setting_record(key)
      if sv.blank?
        parent_value(key) || template_default_value(key) || nil
      else
        sv.value
      end
    end

    def bulk_assign(attributes)
      attributes.each do |(k,v)|
        self[k] = v
      end
    end

    def delete(key)
      @model.setting_values.delete(setting_record(key))
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
      return nil unless @model.class._inheritor.present?
      @model.class._inheritor.parent_settings_for(@model)
    end

    # Use to enumerate the settings
    # eg;
    #
    # model.settings.enumerator.each { |s| ... }
    #
    def enumerator
      Enumerator.new(setting_values)
    end

    def inspect
      @model.reload unless @model.new_record?
      self.to_hash.inspect
    end

    def to_hash
      setting_values.inject({}) do |hash, sv|
        hash[sv.key] = sv.value
        hash
      end.symbolize_keys
    end

    protected
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
        setting_values.select{|sv| sv.key.to_sym == attribute.to_sym }.last # When updating an existing setting_value, the new value comes after the existing value in the array.
      end

      def build_value(key, value)
        @model.setting_values.build(:key => key, :value => value)
      end

      def setting_values
        @model.setting_values
      end
  end
end

module SettingCrazy
  module ClassMethods
    def use_setting_template(template = nil, &block)
      @template = template || block
    end

    def settings_inherit_via(reflection, options = {})
      @inheritor = Inheritor.new(reflection, options)
    end

    def setting_namespace(name, options = {})
      @setting_namespaces ||= {}
      @setting_namespaces[name.to_sym] = Namespace.new(name, options)
    end

    def validate_settings_on_create(validate)
      @validate_settings_on_create = validate
    end

    def _inheritor
      @inheritor
    end

    def _validate_settings_on_create?
      @validate_settings_on_create
    end

    def _setting_namespaces
      @setting_namespaces
    end

    def setting_template(record)
      case @template
        when String  then @template.constantize
        when Class   then @template
        when Proc    then @template.call(record)
      end
    end
  end
end

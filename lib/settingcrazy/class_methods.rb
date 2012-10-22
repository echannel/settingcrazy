module SettingCrazy
  module ClassMethods
    def use_setting_template(template = nil, &block)
      @template = template || block
    end

    def settings_inherit_via(reflection)
      @inherit_via = reflection
      # TODO: Do a reflection look up to make sure its valid
    end

    def _inherit_via
      @inherit_via
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


module SettingCrazy
  class Inheritor
    def initialize(via, options = {})
      # TODO: Do a reflection look up to make sure its valid
      @via              = via
      @parent_namespace = options[:namespace]
    end

    # Returns the appropriate parent settings
    def parent_settings_for(model)
      return nil if model.send(@via).blank?
      association = model.send(@via)
      if pn = parent_namespace(model)
        association.settings.send(pn)
      else
        association.settings
      end
    end

    protected
      def parent_namespace(model)
        case @parent_namespace
          when nil then nil
          when String, Symbol then @parent_namespace
          when Proc
            @parent_namespace.call(model)
        end
      end
  end
end

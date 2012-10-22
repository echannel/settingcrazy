module SettingCrazy
  module Template

    class Enum < Hash
      attr_reader :name, :options

      def initialize(name, options, &block)
        super()
        @name    = name
        @options = options
        instance_eval(&block)
      end

      def value(enum_value, description = enum_value)
        self[description] = enum_value
      end
    end
  end
end

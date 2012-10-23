module SettingCrazy
  class Namespace
    attr_reader :template

    def initialize(name, options = {})
      @name     = name.to_sym
      @template = options[:template]
    end

    def name
      @name.to_s
    end
  end
end

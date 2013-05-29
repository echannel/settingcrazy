module SettingCrazy
  module AttributeMethods
    # Very simple implementation of define method. Required, as ActiveModel define_method is deprecated
    def define_attr_method(name, &block)
      raise ArgumentError, 'Block Required' unless block_given?
      singleton_class.send :define_method, name, &block
    end
  end
end

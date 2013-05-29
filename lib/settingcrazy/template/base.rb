module SettingCrazy
  module Template
    class Base
      extend SettingCrazy::AttributeMethods

      class << self
        # Allows definition of enums in template class. Duplicates existing enums to allow inheritance of enums from parent class without affecting parent enums.
        # Example Usage:
        #
        #   enum :delivery_method, 'Delivery Method', { multiple: false, required: true } do
        #     value 'STANDARD',    'Standard'
        #     value 'ACCELERATED', 'Accelerated'
        #   end
        def enum(id, name=id.to_s, options={}, &block)
          old_enums = self.enums.dup
          define_attr_method(:enums) do
            old_enums.tap do |parent_enums|
              parent_enums[id] = SettingCrazy::Template::Enum.new(name, options, &block)
            end
          end
        end

        # Default enums to empty Hash. Will return structure of enums as defined in template class.
        def enums
          {}
        end

        # Returns the options for the enum with argument key. Response is the third argument passed to enum.
        def enum_options(key)
          enums[key].options
        end

        # Returns an array suitable for use in options_for_select helper
        # Example:
        #
        #   options_for_select(GoogleSettings::Campaign.options(:platform))
        #
        def options(name)
          enum = enums[name]
          return [] if enum.blank?
          enum.to_a
        end

        def name_for(id)
          raise "No setting with id '#{id}'" unless enums.has_key?(id)
          enums[id].name
        end

        # Returns the available options for the setting object
        def available_options(key=nil)
          key.nil? ? enums : enums[key.to_sym]
        end

        # Returns whether single keyword valid
        # TODO: Allow passing of key or array of keys
        def valid_option?(key)
          key = key.to_s.gsub(/\=$/,'').to_sym #strip setter (=) from key, so can just check options hash
          available_options.keys.include?(key)
        end

        def defaults
          {}
        end

        # # Maybe too complicated
        # def self.validator_klass
        #   class_eval <<-STR
        #     class MyValidator < ActiveModel::Validator
        #       validates :display, :presence => true
        #     end
        #   STR
        # end

        # def validator
        #   self.class.validator.new
        # end
      end
    end
  end
end

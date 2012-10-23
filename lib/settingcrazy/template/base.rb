module SettingCrazy
  module Template
    class Base

      class << self

        def enum(id, name=id.to_s, options={}, &block)
          enums[id] = Scenario::Setting::Enum.new(name, options, &block)
        end

        def enums
          @enums ||= {}
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
          key = key.to_getter.to_sym #strip setter (=) from key, so can just check options hash
          template.present? && available_options.keys.include?(key)
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

class SettingsValidator < ActiveModel::Validator
  attr_accessor :record, :settings, :template

  def validate(record)
    record.setting_errors = nil
    self.record  = record

    # Do not validate setting_values for unsaved owner. This is done due to the workflow of the application, where objects are created before the user is able to set settings for them.
    # This behaviour can be overwritten by using 'validate_settings_on_create'
    if record.persisted? || record.class._validate_settings_on_create?
      if record.class._setting_namespaces
        namespaces = record.respond_to?(:available_setting_namespaces) ? record.available_setting_namespaces : record.class._setting_namespaces
        namespaces.each do |name, namespace|
          self.template = namespace.template
          self.settings = record.settings[name]
          validate_template(namespace) if namespace.template
        end
      elsif record.settings.template
        self.settings = record.settings
        self.template = settings.template
        validate_template
      end
      record.errors.add :base, 'Settings are invalid' if record.setting_errors
    end
  end

  protected
    def validate_template(namespace = nil)
      template.enums.symbolize_keys.each do |key, name_value_pairs|
        enum_options  = template.enum_options(key)
        current_value = settings.send(key)

        validate_presence(key, current_value)                               if enum_options[:required]
        validate_singleness(key, current_value)                         unless enum_options[:multiple]
        validate_dependent(key, current_value, enum_options[:dependent])    if enum_options[:dependent] && current_value.present?
        validate_range(key, current_value, name_value_pairs.values)         if enum_options[:type] != 'text' && current_value.present?
        validate_require_if(key, current_value, enum_options[:required_if]) if enum_options[:required_if].present?

        # determine numerical comparisons to be performed
        comparison_operations = enum_options.keys & OPERATORS.keys
        validate_numeric(key, current_value, enum_options, comparison_operations, namespace) if comparison_operations.present? && current_value.present?
      end
    end

    # Validates that a value has been provided for this field
    #@param [Symbol] key The key for this enum of the settings
    #@param [Any] value The value provided for this setting
    def validate_presence(key, value)
      add_templated_error(key, "Setting, '#{template.name_for(key)}', is required") if value.blank?
    end

    # Validates that only a single value
    #@param [Symbol] key The key for this enum of the settings
    #@param [Any] value The value provided for this setting
    def validate_singleness(key, value)
      add_templated_error(key, "Cannot save multiple values for Setting, '#{template.name_for(key)}'") if value.instance_of?(Array)
    end

    # Validates that a value is only provided for this field if another setting has been set to a specified value
    #@param [Symbol] key The key for this enum of the settings
    #@param [Any] value The value provided for this setting
    #@param [Hash] conditions The key value pairs specifying the required settings as keys, and required values for those settings as values
    def validate_dependent(key, value, conditions)
      conditions.each do |dependent_on_key, dependent_on_value|
        add_templated_error(key, "'#{template.name_for(key)}' can only be specified if '#{template.name_for(dependent_on_key)}' is set to '#{human_readable_value_for(dependent_on_key, dependent_on_value)}'") unless settings.send(dependent_on_key) == dependent_on_value
      end
    end

    # Validates that the value is in the allowed range, as specified by the enum
    #@param [Symbol] key The key for this enum of the settings
    #@param [Any] value The value provided for this setting
    #@param [Array] enum_values The possible values the the settings value(s) can be set as
    def validate_range(key, value, enum_values)
      values = value.instance_of?(Array) ? value : [value]
      values.each do |v|
        add_templated_error(key, "'#{v}' is not a valid setting for '#{template.name_for(key)}'") unless enum_values.include?(v)
      end
    end

    # Validates that a value is provided for this field if another setting has been set to a specified value
    #@param [Symbol] key The key for this enum of the settings
    #@param [Any] value The value provided for this setting
    #@param [Hash] conditions The key value pairs specifying the required settings as keys, and required values for those settings as values
    def validate_require_if(key, value, conditions)
      if conditions.all? { |k, v| settings.send(k) == v }
        add_templated_error(key, "Setting, '#{template.name_for(key)}', is required when #{conditions_to_sentence(conditions)}") if value.blank?
      end
    end

    # Validates that a value satisfies the numeric constraints set in its conditions
    #@param [Symbol] key The key for this enum of the settings
    #@param [Any] value The value provided for this setting
    #@param [Hash] conditions The numeric conditions placed on this setting (e.g. { :greater_than => { value: 0 } })
    #@param [Array] comparison_operations The mathematical operations required for numerical validation (e.g [:greater_than, :less_than_or_equal_to])
    def validate_numeric(key, value, conditions, comparison_operations, namespace)
      comparison_operations.each do |comparison_operation|
        comparison_text = comparison_operation.to_s.gsub('_', ' ')
        operator = OPERATORS[comparison_operation]

        # Checking value against a static value
        if conditions[comparison_operation][:value].present?
          unless value.to_f.send(operator, conditions[comparison_operation][:value].to_f)
            add_templated_error(key, "Setting, '#{template.name_for(key)}', must be #{comparison_text} #{conditions[comparison_operation][:value]}")
          end
        end

        # Checking value against an attribute of a model associated with this record
        if conditions[comparison_operation][:association].present?
          compare_numeric_value_with_association(key, value, conditions, comparison_operation, comparison_text, operator)

        # Checking value against another setting attribute of this record
        elsif conditions[comparison_operation][:attribute].present?
          attribute_for_comparison = conditions[comparison_operation][:attribute]
          settings = namespace.present? ? record.settings.send(namespace.name) : record.settings
          unless value.to_f.send(operator, settings.send(attribute_for_comparison).to_f)
            add_templated_error(key, "Setting, '#{template.name_for(key)}', must be #{comparison_text} '#{template.name_for(attribute_for_comparison)}'")
          end
        end
      end
    end

    # Compare numerical value against setting value of associated record
    #@param [Symbol] key The key for this enum of the settings
    #@param [Any] value The value provided for this setting
    #@param [Hash] conditions The numeric conditions placed on this setting (e.g. { :greater_than => { value: 0 } })
    #@param [Symbol] comparison_operation The mathematical operation to be performed (e.g :greater_than)
    #@param [String] comparison_text The human readable version of the comparison text (e.g 'greater than')
    #@param [String] operation The mathematical operator to be applied (e.g '>')
    def compare_numeric_value_with_association(key, value, conditions, comparison_operation, comparison_text, operator)
      namespace = record.settings.inherited_namespace
      association = conditions[comparison_operation][:association]
      association_attribute = conditions[comparison_operation][:attribute]
      association_attribute_name = conditions[comparison_operation][:attribute].to_s.titleize # For error string. Safest way to get this value, as can't assume association has template.

      # Fetch comparison value and association attribute human readable name from associated record, inherited and namespaced if required
      if namespace
        comparison_value           = record.send(association).settings.send(namespace).send(association_attribute).to_f
      else
        comparison_value           = record.send(association).settings.send(association_attribute).to_f
      end

      unless value.to_f.send(operator, comparison_value)
        error_string = "Setting, '#{template.name_for(key)}', must be #{comparison_text} the"\
        " '#{association_attribute_name}' of "\
        "its #{(conditions[comparison_operation][:association]).to_s.titleize}"
        add_templated_error(key, error_string)
      end
    end

    # Adds error to setting_errors object of record, grouping by the setting template used for validation
    def add_templated_error(key, message)
      record.setting_errors                     ||= {}
      record.setting_errors[template.to_s]      ||= {}
      record.setting_errors[template.to_s][key] ||= []
      record.setting_errors[template.to_s][key].push(message)
    end

    def conditions_to_sentence(conditions)
      conditions.inject([]) do |res, (condition_key, condition_value)|
        res.push("'#{template.name_for(condition_key)}' is '#{human_readable_value_for(condition_key, condition_value)}'")
        res
      end.to_sentence
    end

    def human_readable_value_for(enum_key, value)
      template.enums[enum_key].key(value)
    end
end

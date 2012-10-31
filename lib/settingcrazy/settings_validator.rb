class SettingsValidator < ActiveModel::Validator
  attr_accessor :record, :settings, :template

  def validate(record)
    record.setting_errors = nil
    self.record  = record

    if record.persisted? # Not to valid setting_values for unsaved owner
      if record.class._setting_namespaces
        record.class._setting_namespaces.each do |name, namespace|
          self.template = namespace.template
          self.settings = record.settings[name]
          validate_template if namespace.template
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
    def validate_template
      template.enums.symbolize_keys.each do |key, name_value_pairs|
        enum_options  = template.enum_options(key)
        current_value = settings.send(key)

        validate_presence(key, current_value)                            if enum_options[:required]
        validate_singleness(key, current_value)                      unless enum_options[:multiple]
        validate_dependent(key, current_value, enum_options[:dependent]) if enum_options[:dependent] && current_value.present?
        validate_range(key, current_value, name_value_pairs.values)      if enum_options[:type] != 'text' && current_value.present?
      end
    end

    def validate_presence(key, value)
      add_templated_error(key, "Setting, '#{template.name_for(key)}', is required") if value.blank?
    end

    def validate_singleness(key, value)
      add_templated_error(key, "Cannot save multiple values for Setting, '#{template.name_for(key)}'") if value.instance_of?(Array)
    end

    def validate_dependent(key, value, conditions)
      conditions.each do |dependent_on_key, dependent_on_value|
        add_templated_error(key, "'#{template.name_for(key)}' can only be specified if '#{template.name_for(dependent_on_key)}' is set to '#{dependent_on_value}'") unless settings.send(dependent_on_key) == dependent_on_value
      end
    end

    def validate_range(key, value, enum_values)
      values = value.instance_of?(Array) ? value : [value]
      values.each do |v|
        add_template_error(key, "'#{v}' is not a valid setting for '#{template.name_for(key)}'") unless enum_values.include?(v)
      end
    end

    def add_templated_error(key, message)
      record.setting_errors                     ||= {}
      record.setting_errors[template.to_s]      ||= {}
      record.setting_errors[template.to_s][key] ||= []
      record.setting_errors[template.to_s][key].push(message)
    end
end

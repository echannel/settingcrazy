class SettingsValidator < ActiveModel::Validator
  attr_accessor :record, :settings, :template

  def validate(record)
    self.record  = record
    self.settings = record.settings
    self.template = settings.template

    if record.persisted? && template.present? # Not to valid setting_values for unsaved owner & Validate only if the template exists
      template.enums.symbolize_keys.each do |key, name_value_pairs|
        enum_options  = template.enum_options(key)
        current_value = settings.send(key)

        validate_presence(key, current_value)                            if enum_options[:required]
        validate_singleness(key, current_value)                      unless enum_options[:multiple]
        validate_dependent(key, current_value, enum_options[:dependent]) if enum_options[:dependent] && current_value.present?
        validate_range(key, current_value, name_value_pairs.values)      if enum_options[:type] != 'text' && current_value.present?
      end
    end
  end

  protected
    def validate_presence(key, value)
      @record.errors.add key, "Setting, '#{template.name_for(key)}', is required" if value.blank?
    end

    def validate_singleness(key, value)
      @record.errors.add key, "Cannot save multiple values for Setting, '#{template.name_for(key)}'" if value.instance_of?(Array)
    end

    def validate_dependent(key, value, conditions)
      conditions.each do |dependent_on_key, dependent_on_value|
        @record.errors.add key, "'#{template.name_for(key)}' can only be specified if '#{template.name_for(dependent_on_key)}' is set to '#{dependent_on_value}'" unless settings.send(dependent_on_key) == dependent_on_value
      end
    end

    def validate_range(key, value, enum_values)
      values = value.instance_of?(Array) ? value : [value]
      values.each do |v|
        @record.errors.add key, "'#{v}' is not a valid setting for '#{template.name_for(key)}'" unless enum_values.include?(v)
      end
    end
end

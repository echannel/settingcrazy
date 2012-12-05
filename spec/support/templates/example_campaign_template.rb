class ExampleCampaignTemplate < SettingCrazy::Template::Base
  enum :required_key, 'RequiredKey', { required: true } do
    value 'true', 'RequiredKey is true'
  end

  enum :multiple_key, 'MultipleKey', { multiple: true } do
    value 'foo', 'MultipleKey has foo'
    value 'bar', 'MultipleKey has bar'
  end

  enum :single_key, 'SingleKey', { multiple: false } do
    value 'foo', 'SingleKey is foo'
    value 'bar', 'SingleKey is bar'
  end

  enum :dependee_key, 'DependeeKey' do
    value 'foo', 'DependeeKey is foo'
    value 'bar', 'DependeeKey is bar'
    value 'baz', 'DependeeKey is baz'
  end

  enum :dependent_key, 'DependentKey', {dependent: {dependee_key: 'bar'}} do
    value 'BAR', 'DependentKey is BAR'
  end

  enum :required_if_key, 'RequiredIfKey', { required_if: {dependee_key: 'baz'} } do
    value 'true', 'RequiredIfKey is true'
  end

  enum :greater_than_value_key, 'GreaterThanValueKey', { type: 'text', greater_than: { value: 0 } } do
    value '', 'GreaterThanValueKey text value'
  end

  enum :greater_than_attribute_key, 'GreaterThanAttributeKey', { type: 'text', greater_than: { attribute: :greater_than_value_key } } do
    value '', 'GreaterThanValueKey text value'
  end

  enum :greater_than_association_attribute_key, 'GreaterThanAssociationAttributeKey', { type: 'text', greater_than: { association: :scenario, attribute: :greater_than_value_key } } do
    value '', 'GreaterThanAssociationAttributeKey text value'
  end
end

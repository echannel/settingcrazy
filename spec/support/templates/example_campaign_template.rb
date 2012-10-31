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
end

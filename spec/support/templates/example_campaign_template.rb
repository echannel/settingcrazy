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
  end

  enum :dependent_key, 'DependentKey', {dependent: {dependee_key: 'bar'}} do
    value 'BAR', 'DependentKey is BAR'
  end
end

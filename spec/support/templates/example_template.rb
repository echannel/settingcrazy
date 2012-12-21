class ExampleTemplate < SettingCrazy::Template::Base
  def self.defaults
    {
      :foo => "1234",
      :bar => "A string default"
    }
  end

  enum :foo, 'Foo', type: 'text' do
    value '', 'Foo'
  end

  enum :bar, 'Bar', type: 'text' do
    value '', 'bar'
  end

  enum :required_key, 'RequiredKey', { type: 'text', required: true } do
    value '1234', 'RequiredKey is 1234'
    value '5678', 'RequiredKey is 5678'
  end

  enum :daily_budget, 'Daily Budget', type: 'text', greater_than: { value: 0 } do
    value '', 'Daily Budget'
  end

  enum :cpc, 'Cost per Click', type: 'text', less_than_or_equal_to: { attribute: :daily_budget } do
    value '', 'CPC'
  end
end

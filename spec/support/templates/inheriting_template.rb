class InheritingTemplate < SettingCrazy::Template::Base
  enums_inherit_via ExampleTemplate

  # Overwrites an enum inherited from ExampleTemplate
  enum :foo, 'Foo', type: 'text' do
    value 'Foo1Key', 'Foo1Value'
    value 'Foo2Key', 'Foo2Value'
  end

  # Adds a new enum that is not present in ExampleTemplate
  enum :baz, 'Baz', type: 'text' do
    value 'Baz1Key', 'Baz1Value'
    value 'Baz2Key', 'Baz2Value'
  end
end

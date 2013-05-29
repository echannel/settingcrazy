class InheritingTemplate < ExampleTemplate
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

  # Adds another enum
  enum :example_enum,  'Example Enum', { multiple: false } do
    value 'true', 'Totally True'
    value 'false', 'Totally Not True'
  end
end

class ExampleTemplate < SettingCrazy::Template::Base
  def self.valid_option?(key)
    %w(foo bar required_key).include?(key.to_s)
  end

  def self.defaults
    {
      :foo => "1234",
      :bar => "A string default"
    }
  end

  enum :required_key, 'RequiredKey', { required: true } do
    value '1234', 'RequiredKey is 1234'
    value '5678', 'RequiredKey is 5678'
  end
end

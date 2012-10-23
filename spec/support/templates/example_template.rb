class ExampleTemplate < SettingCrazy::Template::Base
  def self.valid_option?(key)
    %w(foo bar).include?(key.to_s)
  end

  def self.defaults
    {
      :foo => "1234",
      :bar => "A string default"
    }
  end
end

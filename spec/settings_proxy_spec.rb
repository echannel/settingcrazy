require 'spec_helper'

class ExampleTemplate
  def self.valid_option?(key)
    puts "Checking #{key}"
    %w(foo bar).include?(key.to_s)
  end

  def self.defaults
    {
      :foo => "1234",
      :bar => "A string default"
    }
  end
end

describe SettingCrazy::SettingsProxy do
  let(:model) { VendorInstance.create(:name => "VI") }

  context "no template" do
    subject   { SettingCrazy::SettingsProxy.new(model, nil) }
    before    { subject.foo = "bar"; model.save! }
    its(:foo) { should == 'bar' }
    its(:oth) { should be(nil) }
    it        { subject[:foo].should == 'bar' }
    it        { subject[:oth].should be(nil) }

    describe "update a value" do
      before { subject.foo = "different"; model.save! }
      its(:foo) { should == "different" }
    end
  end

  context "a template is provided" do
    let(:template) { ExampleTemplate }
    subject   { SettingCrazy::SettingsProxy.new(model, template) }
    before    { subject.foo = "1234"; model.save! }
    its(:foo) { should == "1234" }
    its(:bar) { should == "A string default" }
    it        { subject[:foo].should == "1234" }
    it        { subject[:bar].should == "A string default" }

    it "should raise if we try to get an invalid option" do
      -> {
        subject.unknown
      }.should raise_error(ActiveRecord::UnknownAttributeError)
    end
  end
end

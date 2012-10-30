require 'spec_helper'

describe SettingCrazy::SettingsProxy do
  let(:model) { VendorInstance.create(:name => "VI") }

  context "no template" do
    subject   { SettingCrazy::SettingsProxy.new(model, nil) }

    context "single values" do
      before    { subject.foo = "bar"; model.save! }
      its(:foo) { should == 'bar' }
      its(:oth) { should be(nil) }
      it        { subject[:foo].should == 'bar' }
      it        { subject[:oth].should be(nil) }
      it        { subject.to_hash.should == {foo: 'bar'} }

      describe "update a value" do
        before { subject.foo = "different" }
        its(:foo) { should == "different" }
      end
    end

    context "multiple values" do
      before do
        subject.foo = %w(a b c)
        model.save!
      end

      its(:foo) { should == [ 'a', 'b', 'c' ] }

      describe "update a value" do
        before do
          subject.foo = %w(d e f)
        end
        its(:foo) { should == [ 'd', 'e', 'f' ] }
      end
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

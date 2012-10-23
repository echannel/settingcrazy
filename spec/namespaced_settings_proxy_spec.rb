require 'spec_helper'

describe SettingCrazy::NamespacedSettingsProxy do
  let(:model) { VendorInstance.create(:name => "VI") }

  context "no template" do
    let(:namespace) { SettingCrazy::Namespace.new('google') }
    subject         { SettingCrazy::NamespacedSettingsProxy.new(model, namespace) }

    context "single values" do
      before    { subject.foo = "bar"; model.save! }
      its(:foo) { should == 'bar' }
      its(:oth) { should be(nil) }
      it        { subject[:foo].should == 'bar' }
      it        { subject[:oth].should be(nil) }

      it "should apply the namespace to the setting values" do
        model.setting_values(true).first.namespace.should == 'google'
      end

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
end

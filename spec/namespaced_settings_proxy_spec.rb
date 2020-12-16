require 'spec_helper'

describe SettingCrazy::NamespacedSettingsProxy do
  context "no template" do
    let(:model) { VendorInstance.create(:name => "VI") }
    let(:namespace) { SettingCrazy::Namespace.new('google') }
    subject         { SettingCrazy::NamespacedSettingsProxy.new(model, namespace) }

    context "single values" do
      before(:each)    { subject.foo = "bar"; model.save! }
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

  describe 'one settable object with multiple namespaces' do
    let(:scenario) { Scenario.create }
    subject        { scenario.settings }

    context 'not share setting_values' do
      before do
        scenario.settings.google.foo = 'bar'
        scenario.save!
      end
      it { subject.google.inspect.should == '{:foo=>"bar"}' }
      it { subject.google.foo.should     == 'bar' }
      it { subject.yahoo.inspect.should  == '{}' }
      it { subject.yahoo.foo.should      be(nil) }
    end

    context 'has unique values' do
      before do
        scenario.settings.google.foo = 'bar'
        scenario.settings.yahoo.foo  = 'baz'
        scenario.save!
      end
      it { subject.google.inspect.should == '{:foo=>"bar"}' }
      it { subject.google.foo.should     == 'bar' }
      it { subject.yahoo.inspect.should  == '{:foo=>"baz"}' }
      it { subject.yahoo.foo.should      == 'baz' }
    end
  end
end

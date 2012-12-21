require 'spec_helper'

describe SettingCrazy do
  describe "class methods" do

  end

  describe "settings" do

    context "without namespaces" do
      let(:model) { VendorInstance.create(:name => "VI") }
      subject     { model.settings }
      it          { should be_a(SettingCrazy::SettingsProxy) }
    end

    context "with namespaces" do
      let(:model)   { Scenario.create(:name => "Scenario") }
      subject       { model.settings }
      it            { should be_a(SettingCrazy::SettingsProxy) }
      its(:google)  { should be_a(SettingCrazy::SettingsProxy) }
      its(:yahoo)   { should be_a(SettingCrazy::SettingsProxy) }
      its(:unknown) { should be_nil }

      describe "setting and getting" do
        before do
          model.settings.google.foo = "bar"
          model.save!
        end

        subject   { model.settings.google }
        its(:foo) { should == 'bar' }

        it "should not be set in other namespaces" do
          model.settings.yahoo.foo.should be_nil
        end
      end
    end

    context "with namespaces and templates" do
      let(:model)   { TemplatedScenario.create(:name => "Scenario") }
      subject       { model.settings }
      it            { should be_a(SettingCrazy::SettingsProxy) }
      its(:google)  { should be_a(SettingCrazy::SettingsProxy) }
      its(:yahoo)   { should be_a(SettingCrazy::SettingsProxy) }
      its(:unknown) { should be_nil }

      it "should have a template for google" do
        subject.google.template.should == ExampleTemplate
      end

      describe "setting and getting" do
        before do
          model.settings.google.foo = "bar"
          model.settings.google.required_key = '1234'
          model.settings.yahoo.required_key = '1234'
          model.valid?
          p model.setting_errors
          model.save!
        end

        subject   { model.settings.google }
        its(:foo) { should == 'bar' }

        it "should not be set in other namespaces" do
          model.settings.yahoo.foo.should_not == 'bar'
        end

        it "should not allow settings not in the templated namespace" do
          -> {
            model.settings.google.not_in_template
          }.should raise_error(ActiveRecord::UnknownAttributeError)
        end

        it "should ALLOW settings in the UNtemplated namespace" do
          -> {
            model.settings.yahoo.not_in_template_but_we_dont_care
          }.should_not raise_error(ActiveRecord::UnknownAttributeError)
        end
      end
    end
  end
end

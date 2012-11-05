require 'spec_helper'

describe SettingsValidator do
  context 'no template' do
    context 'model not saved' do
      subject { VendorInstance.new(:name => "VI") }
      it      { should be_valid }
    end

    context 'model saved' do
      subject { VendorInstance.create(:name => "VI") }
      it      { should be_valid }
    end
  end

  context 'a template is provided' do
    context 'model not saved' do
      subject { TemplatedCampaign.new(:name => "TemplatedCampaign") }
      it      { should be_valid }
    end

    context 'model saved' do
      subject { TemplatedCampaign.create(:name => "TemplatedCampaign") }
      it      { should_not be_valid }

      context 'validates presence' do
        context 'required_key does not exist' do
          before { subject.valid? }
          it     { subject.errors.messages[:base].should include('Settings are invalid') }
          it     { subject.setting_errors['ExampleCampaignTemplate'][:required_key].should include("Setting, 'RequiredKey', is required") }
        end

        context 'required_key exists' do
          before { subject.settings.required_key = 'true'; subject.save! }
          it     { should be_valid }
        end
      end

      context 'validates singleness' do
        before { subject.settings.required_key = 'true'; subject.valid? }

        context 'multiple_key' do
          context 'has one value' do
            before { subject.settings.multiple_key = 'foo', 'bar' }
            it     { should be_valid }
          end

          context 'has more than one values' do
            before { subject.settings.multiple_key = ['foo', 'bar'] }
            it     { should be_valid }
          end
        end

        context 'single_key' do
          context 'assigns one value' do
            before { subject.settings.single_key = 'foo' }
            it     { should be_valid }
          end

          context 'assigns more than one values' do
            before { subject.settings.single_key = ['foo', 'bar']; subject.valid? }
            it     { should_not be_valid }
            it     { subject.errors.messages[:base].should include('Settings are invalid') }
            it     { subject.setting_errors['ExampleCampaignTemplate'][:single_key].should include("Cannot save multiple values for Setting, 'SingleKey'") }
          end
        end
      end

      context 'validates dependency' do
        before { subject.settings.required_key = 'true'; subject.valid? }

        context 'dependent key' do
          context 'dependee value does not exist' do
            before { subject.settings.dependent_key = 'BAR'; subject.valid? }
            it     { should_not be_valid }
            it     { subject.setting_errors['ExampleCampaignTemplate'][:dependent_key].should include("'DependentKey' can only be specified if 'DependeeKey' is set to 'DependeeKey is bar'") }
          end

          context 'dependee value is not satisfied' do
            before { subject.settings = {dependee_key: 'foo', dependent_key: 'BAR'}; subject.valid? }
            it     { should_not be_valid }
            it     { subject.setting_errors['ExampleCampaignTemplate'][:dependent_key].should include("'DependentKey' can only be specified if 'DependeeKey' is set to 'DependeeKey is bar'") }
          end

          context 'dependee value is satisfied' do
            before { subject.settings = {dependee_key: 'bar', dependent_key: 'BAR'} }
            it     { should be_valid }
          end
        end
      end

      context 'validates values' do
        before { subject.settings.required_key = 'true'; subject.valid? }

        context 'single key' do
          context 'invalid value' do
            before { subject.settings.single_key = 'foobar'; subject.valid? }
            it     { should_not be_valid }
            it     { subject.setting_errors['ExampleCampaignTemplate'][:single_key].should include("'foobar' is not a valid setting for 'SingleKey'") }
          end

          context 'valid value' do
            before { subject.settings.single_key = 'bar' }
            it     { should be_valid }
          end
        end

        context 'multiple key' do
          context 'invalid value' do
            before { subject.settings.multiple_key = ['foo', 'foobar']; subject.valid? }
            it     { should_not be_valid }
            it     { subject.setting_errors['ExampleCampaignTemplate'][:multiple_key].should include("'foobar' is not a valid setting for 'MultipleKey'") }
          end

          context 'valid value' do
            before { subject.settings.multiple_key = ['foo', 'bar'] }
            it     { should be_valid }
          end
        end
      end

      context 'validates required_if' do
        before { subject.settings.required_key = 'true' }
        context 'dependee key does not exist' do
          before { subject.valid? }
          it     { should be_valid }
        end

        context 'dependee key exists but is not required value' do
          before { subject.settings.dependee_key = 'foo'; subject.valid? }
          it     { should be_valid }
        end

        context 'dependee key exists and is required value' do
          before { subject.settings.dependee_key = 'baz' }

          context 'required_if_key does not exist' do
            before { subject.valid? }
            it     { should_not be_valid }
            it     { subject.setting_errors['ExampleCampaignTemplate'][:required_if_key].should include("Setting, 'RequiredIfKey', is required when 'DependeeKey' is 'DependeeKey is baz'") }
          end

          context 'required_if_key exists' do
            before { subject.settings.required_if_key = 'true'; subject.valid? }
            it     { should be_valid }
          end
        end
      end

      context 'validates greater_than' do
        before { subject.settings.required_key = 'true' }
        context 'for a setting that does not satisfy the requirements' do
          before  do
            subject.settings.greater_than_key = 0
            subject.valid?
          end

          it      { should_not be_valid }
          it      { subject.setting_errors['ExampleCampaignTemplate'][:greater_than_key].should include("Setting, 'GreaterThanKey', must be greater than 0") }
        end

        context 'for a setting that satisfies the requirements' do
          before  do
            subject.settings.greater_than_key = 1
            subject.valid?
          end
          it      { should be_valid }
        end
      end
    end
  end

  context 'multiple namespaces' do
    subject { TemplatedScenario.create(:name => "Scenario") }

    context 'validates all namespaces' do
      before { subject.valid? }
      it     { subject.errors.messages[:base].should include('Settings are invalid') }
      it     { subject.setting_errors['ExampleTemplate'][:required_key].should include("Setting, 'RequiredKey', is required") }
    end

    context 'validates available namespaces only' do
      before { subject.stubs(:available_setting_namespaces).returns(subject.class._setting_namespaces.slice(:yahoo)) }
      it     { should be_valid }
    end
  end
end

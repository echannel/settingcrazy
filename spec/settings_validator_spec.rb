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
          it     { subject.errors.messages[:required_key].should include("Setting, 'RequiredKey', is required") }
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
            it     { subject.errors.messages[:single_key].should include("Cannot save multiple values for Setting, 'SingleKey'") }
          end
        end
      end

      context 'validates dependency' do
        before { subject.settings.required_key = 'true'; subject.valid? }

        context 'dependent key' do
          context 'dependee value does not exist' do
            before { subject.settings.dependent_key = 'BAR'; subject.valid? }
            it     { should_not be_valid }
            it     { subject.errors.messages[:dependent_key].should include("'DependentKey' can only be specified if 'DependeeKey' is set to 'bar'") }
          end

          context 'dependee value is not satisfied' do
            before { subject.settings = {dependee_key: 'foo', dependent_key: 'BAR'}; subject.valid? }
            it     { should_not be_valid }
            it     { subject.errors.messages[:dependent_key].should include("'DependentKey' can only be specified if 'DependeeKey' is set to 'bar'") }
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
            it     { subject.errors.messages[:single_key].should include("'foobar' is not a valid setting for 'SingleKey'") }
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
            it     { subject.errors.messages[:multiple_key].should include("'foobar' is not a valid setting for 'MultipleKey'") }
          end

          context 'valid value' do
            before { subject.settings.multiple_key = ['foo', 'bar'] }
            it     { should be_valid }
          end
        end
      end
    end
  end
end

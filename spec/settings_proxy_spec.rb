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

    context 'respond_to?' do
      context 'key has not been set' do
        it { subject.respond_to?(:foo).should be_false }
      end

      context 'key has been set' do
        before { subject.foo = 'bar'; model.save! }
        it     { subject.respond_to?(:foo).should be_true }
      end
    end
  end

  context "a template is provided" do
    let(:model)        { TemplatedCampaign.create(:name => 'TC') }
    subject            { model.settings }
    before             { subject.required_key = 'true'; model.save! }
    its(:required_key) { should == 'true' }
    it                 { subject[:required_key].should == 'true' }

    it "should raise if we try to get an invalid option" do
      -> {
        subject.unknown
      }.should raise_error(ActiveRecord::UnknownAttributeError)
    end

    context 'respond_to?' do
      context 'key is not in enums' do
        it { subject.respond_to?(:undefined_key).should be_false }
      end

      context 'key is in enums' do
        it { subject.respond_to?(:required_key).should be_true }
      end
    end
  end

  describe 'retrieving model to which settings are assigned' do
    let(:model)        { TemplatedCampaign.create(:name => 'TC Fetch Test') }
    subject            { model.settings }

    it                { should respond_to(:model) }
    its(:model)       { should == model }
  end
end

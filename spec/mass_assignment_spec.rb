require 'spec_helper'

describe VendorInstance do
  let(:model) { VendorInstance.create(:name => "VI") }
  subject { model.settings }

  context "settings direct assignment" do
    before do
      model.settings = {
        :foo => "1234",
        :bar => "abcd"
      }
      model.save!
    end

    it { expect(subject.foo).to eq('1234') }
    it { expect(subject.bar).to eq('abcd') }
  end

  context "mass assignment" do
    before do
      model.attributes = {
        :settings => {
          :foo => "some value",
          :wee => "another",
        }
      }
      model.save!
    end

    it { expect(subject.foo).to eq('some value') }
    it { expect(subject.wee).to eq('another') }
  end

  describe "setting namespaces" do
    let(:model) { Scenario.create(:name => "Scenario") }
    subject     { model.settings.google }

    context "direct assignment" do
      before do
        model.settings.google = {
          :foo => "1234",
          :bar => "abcd"
        }
        model.save!
      end

      it { expect(subject.foo).to eq('1234') }
      it { expect(subject.bar).to eq('abcd') }
    end

    context "mass assignment" do
      before do
        model.attributes = {
          :settings => {
            :google => {
              :foo => "some value",
              :wee => "another",
            }
          }
        }
        model.save!
      end

      it { expect(subject.foo).to eq('some value') }
      it { expect(subject.wee).to eq('another') }
    end
  end
end

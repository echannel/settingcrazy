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

    its(:foo) { should == "1234" }
    its(:bar) { should == "abcd" }
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

    its(:foo) { should == "some value" }
    its(:wee) { should == "another" }
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

      its(:foo) { should == "1234" }
      its(:bar) { should == "abcd" }
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

      its(:foo) { should == "some value" }
      its(:wee) { should == "another" }
    end
  end
end

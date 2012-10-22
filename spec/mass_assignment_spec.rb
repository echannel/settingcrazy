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
      # TODO: We ideally wouldn't need this
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
end

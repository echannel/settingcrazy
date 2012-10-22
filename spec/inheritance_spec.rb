require 'spec_helper'

describe Duck do
  describe "settings from parent" do
    subject { duck.settings }

    context "when parent present" do
      let!(:farm) { Farm.create(:name => "Old MacDonald's") }
      let!(:duck) { farm.ducks.create(:name => "Drake", :quacks => 10) }
      subject     { duck.settings }
      
      before do
        farm.settings.color = "brown"
        farm.save!
      end

      its(:color) { should == "brown" }
    end

    context "when there is no parent" do
      let!(:duck) { Duck.create(:name => "Drake", :quacks => 10) }
      its(:color) { should be(nil) }
    end
  end
    
  context "when the parent has a template" do
    subject { note.settings }

    context "and the parent is present" do
      let!(:_case) { Case.create(:name => "Snowtown") }
      let!(:note)  { _case.notes.create(:name => "The Murderer") }
      its(:foo)    { should == "1234" }
    end

    context "but the parent is missing" do
      let!(:note) { Note.create(:name => "Orphaned") }
      its(:foo)   { should be(nil) }
    end
  end
end

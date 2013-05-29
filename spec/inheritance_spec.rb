require 'spec_helper'

describe SettingCrazy do
  describe "settings from parent" do

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
      subject     { duck.settings }
      its(:color) { should be(nil) }
    end

    context "from a specific namespace on the parent" do
      let!(:scenario) { Scenario.create(:name => "Scen") }
      let!(:campaign) { scenario.campaigns.create(:name => "Regular campaign") }
      subject         { campaign.settings }

      before do
        scenario.settings.yahoo.network = "don't care"
        scenario.settings.google.network = "search"
        scenario.save!
      end

      its(:network) { should == "search" }
    end

    context "from a specific namespace on the parent but set via a Proc" do
      let!(:scenario)           { Scenario.create(:name => "Scen") }
      let!(:clever_campaign_g)  { scenario.clever_campaigns.create(:name => "Clever campaign", :setting_namespace => "google") }
      let!(:clever_campaign_y)  { scenario.clever_campaigns.create(:name => "Clever campaign", :setting_namespace => "yahoo") }

      before do
        scenario.settings.yahoo.network = "something"
        scenario.settings.google.network = "another thing"
        scenario.save!
      end

      context "yahoo" do
        subject       { clever_campaign_y.settings }
        its(:network) { should == "something" }
      end

      context "google" do
        subject       { clever_campaign_g.settings }
        its(:network) { should == "another thing" }
      end
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

  describe 'template enumeration inheritance' do
    let(:templated_case) { Case.create(name: 'templated case') }
    let(:inheriting_templated_scenario) { InheritedTemplatedScenario.create(name: "scenario with inheritance") }

    subject { inheriting_templated_scenario.settings.template.enums }

    it 'inherits the settings of the inherited template' do
      (subject.keys & templated_case.settings.template.enums.keys).should == templated_case.settings.template.enums.keys
    end

    describe 'specifying new keys in the inheriting template' do
      it 'allows new setting enums to be added' do
        subject.count.should == templated_case.settings.template.enums.count + 1
      end

      it 'adds the new enums to the enum set' do
        subject.keys.include?(:baz).should be_true
      end

      it 'does not add the new enum to the template being inherited from' do
        templated_case.settings.template.enums.keys.include?(:baz).should_not be_true
      end
    end

    describe 'overwriting inherited enums' do
      it 'allows overwriting of inherited enums' do
        subject[:foo].should == { 'Foo1Value' => 'Foo1Key', 'Foo2Value' => 'Foo2Key' }
      end

      it 'does not affect the inherited template settings' do
        templated_case.settings.template.enums[:foo].should == { 'Foo' => '' }
      end
    end

  end
end

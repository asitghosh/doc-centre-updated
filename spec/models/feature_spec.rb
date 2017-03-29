require 'spec_helper'

describe Feature do
  before do
    #  init_channel_partners
  end

  subject(:feature) { FactoryGirl.build(:feature, :published) }
  let(:past_release) { FactoryGirl.build(:release, :past, :published) }
  let(:future_release) { FactoryGirl.build(:release, :future, :published) }
  let(:future_feature) { FactoryGirl.build(:feature, :published, :release => future_release) }
  let(:past_feature) { FactoryGirl.build(:feature, :published, :release => past_release) }

  it { should respond_to(:title) }
  it { should respond_to(:summary) }
  it { should respond_to(:content) }
  it { should respond_to(:release) }
  it { should respond_to(:channel_partners) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:summary) }

  it { should be_valid }


  describe "#shown?" do
    it "should be false for past features" do
      past_feature.shown?.should be_false
    end

    it "should be true for future features" do
      future_feature.shown?.should be_true
    end

    it "should be true for unassigned features" do
      feature.shown?.should be_true
    end
  end

end
require 'spec_helper'

describe ChannelPartner do
  subject(:channelpartner) { FactoryGirl.build(:channel_partner) }

  it { should respond_to(:name) }
  it { should respond_to(:open_id_address) }
  it { should respond_to(:subdomain) }
  it { should respond_to(:users) }
  it { should respond_to(:logo) }
  it { should respond_to(:color) }
  it { should respond_to(:account_rep_ids) }
  it { should respond_to(:custom_links) }
  it { should respond_to(:able_to_see_releases) }
  it { should respond_to(:able_to_see_user_guides) }
  it { should respond_to(:able_to_see_faqs) }
  it { should respond_to(:able_to_see_roadmaps) }

  it { should be_valid }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:subdomain) }
  it { should validate_uniqueness_of(:subdomain) }

  it "should be invalid when day_to_send has value and time_to_send does not" do
    channelpartner.day_to_send_latest_release = "Monday"
    channelpartner.should_not be_valid
  end

  describe "notification emails" do
    let!(:release) { FactoryGirl.create(:release, :present, :published) }

    before do
      channelpartner.save
      REDIS_WORKER.flushdb
      Resque.inline = true
      ResqueSpec.reset!
      PdfGenerator.any_instance.stub(:mark_as) { true }
    end

    it "should queue an email" do
      channelpartner.send_latest_release
      PdfGeneratorAndEmailer.should have_queue_size_of(1)
    end
  end

  describe "notification emails when the partner isn't allowed to see the release" do
    let!(:release) { FactoryGirl.create(:release, :present, :published) }

    before do

      channelpartner.able_to_see_releases = false
      channelpartner.save
      REDIS_WORKER.flushdb
      Resque.inline = true
      ResqueSpec.reset!
      PdfGenerator.any_instance.stub(:mark_as) { true }
    end

    after do
      channelpartner.able_to_see_releases = true
      channelpartner.save
    end

    it "shouldn't queue an email" do
      channelpartner.send_latest_release
      PdfGeneratorAndEmailer.should have_queue_size_of(0)
    end
  end

  describe "default abilities" do
    it "should allow releases" do
      channelpartner.should be_able_to_see_releases
    end

    it "should allow faqs" do
      channelpartner.should be_able_to_see_faqs
    end

    it "should allow roadmap" do
      channelpartner.should be_able_to_see_roadmaps
    end

    it "should allow user guides" do
      channelpartner.should be_able_to_see_user_guides
    end
  end

  describe "no releases" do
    it "should not allow releases" do
      channelpartner.able_to_see_releases = false
      channelpartner.should_not be_able_to_see_releases
    end
  end

  describe "no faqs" do
    it "should not allow faqs" do
      channelpartner.able_to_see_faqs = false
      channelpartner.should_not be_able_to_see_faqs
    end
  end

  describe "no user guides" do
    it "should not allow user guides" do
      channelpartner.able_to_see_user_guides = false
      channelpartner.should_not be_able_to_see_user_guides
    end
  end

  describe "no roadmaps" do
    it "should not allow roadmaps" do
      channelpartner.able_to_see_roadmaps = false
      channelpartner.should_not be_able_to_see_roadmaps
    end
  end

end

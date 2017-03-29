require 'spec_helper'

describe Hotfix do
  before do
    init_channel_partners
  end

  let( :release ) { FactoryGirl.create(:release, :published, :past) }
  let(:user) { FactoryGirl.create(:channel_admin, :channel_partner => @dt )}
  let!(:hotfix) { release.hotfixes.create( :number => "#{release.title}.1", :content => "content", :pub_status => "published" )}
  let!(:hotfix2) { release.hotfixes.create( :number => "#{release.title}.2", :content => "This is some AppDirect content", :channel_partner_ids => [@appdirect.id], :pub_status => "published") }
  let!(:draft_hotfix) { release.hotfixes.create(:number => "#{release.title}.3", :content => "This is some AppDirect content", :pub_status => "draft" )}
  subject { hotfix } # can't shorthand this as the lazy load keeps the scope test below from passing.

  it { should respond_to :number }
  it { should respond_to :content }
  it { should respond_to :release }
  it { should respond_to :channel_partners }
  it { should validate_presence_of(:number) }
  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:release_id) }

  describe "public with specifics for" do
    it "should only find one hotfix for the channel_admin" do
      release.hotfixes.public_with_specifics_for(user.channel_partner.id).count.should eq 1
    end
  end

  describe "state changes" do
    it "when draft shouldn't queue emails" do
      draft_hotfix.save
      PdfGeneratorAndEmailer.should have_queue_size_of(0)
    end
    
    it "when published should queue emails" do
      draft_hotfix.publish!
      PdfGeneratorAndEmailer.should have_queue_size_of(ChannelPartner.where("able_to_see_releases IS TRUE").count)
    end
  end

end

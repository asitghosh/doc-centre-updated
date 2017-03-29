require 'spec_helper'

describe Release do
  before do
    init_channel_partners
  end

  let!(:release) { FactoryGirl.create(:release, :present, :published) }
  let!(:old_release) { FactoryGirl.create(:release, :past, :published)}
  let(:user){ FactoryGirl.create(:user, :channel_partner_id => @att.id) }
  let(:marketplace_improvments_passage){ release.passages.create(FactoryGirl.attributes_for(:passage, :type_name => "marketplace_improvements"))}
  let(:api_improvements_passage){ release.passages.create(FactoryGirl.attributes_for(:passage, :type_name => "api_improvements")) }

  subject { release }

  it { should respond_to(:title) }
  it { should respond_to(:release_date) }
  it { should respond_to(:summary) }
  it { should respond_to(:channel_specific_contents) }
  it { should respond_to(:features) }
  it { should respond_to(:slug) }
  it { should respond_to(:corporate_portal) }
  it { should respond_to(:hotfixes) }

  #papertrail
  it { should respond_to(:versions) }

  #autosave
  it { should respond_to(:autosaves) }

  it { should validate_uniqueness_of(:title) }
  it { should validate_presence_of(:release_date) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:summary) }

  it { should be_valid }

  context 'scopes and methods' do

    describe 'scopes' do
      describe "published" do
        it "should only have 1 entries" do
          Release.published.length.should eq 2
        end
      end


      describe "released" do
        it "should only have 1 entries" do
          Release.released.length.should eq 2
        end
      end

      describe "current" do
        it "should find present" do
          Release.current.first.id.should eq release.id
        end
      end

      describe "created or updated since" do
        it "should find both releases" do
          Release.created_or_updated_since(1.week.ago, user).length.should eq 2
        end
      end
    end

    describe "associated passages" do
      it "shouldn't mix up the types" do
        release.marketplace_improvements_passages.should_not include api_improvements_passage
      end
    end

    describe "release type" do
      it "should return draft when draft" do
        release.pub_status = 'draft'
        release.release_type.should eq "draft"
      end

      it "should return current when current" do
        release.release_date = 1.day.ago
        release.release_type.should eq "current"
      end

      it "should return future when future" do
        release.release_date = nil
        release.release_type.should eq "future"
      end

      it "should return past when already released" do
        release.stub(:released?).and_return(true)
        release.stub(:current?).and_return(false)
        release.release_type.should eq "past"
      end
    end

    describe "States" do
      describe "published" do
        it "should include state 'released'" do
          release.pub_status = 'released'
          release.published?.should be_true
        end

        it "should include state 'revised'" do
          release.pub_status = 'revised'
          release.published?.should be_true
        end

        it "should include state 'master'" do
          release.pub_status = 'master'
          release.published?.should be_true
        end

        it "should not include state 'draft'" do
          release.pub_status = 'draft'
          release.published?.should be_false
        end
      end
    end

    describe "PDF emailing" do
      before do
        REDIS_WORKER.flushdb
        Resque.inline = true
        ResqueSpec.reset!
        PdfGenerator.any_instance.stub(:mark_as) { true }
      end

      describe "draft" do
        it "shouldn't queue anything" do
          release.redraft!
          PdfGeneratorAndEmailer.should have_queue_size_of(0)
        end
      end

      describe "release" do
        it "shouldn't queue anything" do
          release.redraft!
          release.revise!
          PdfGeneratorAndEmailer.should have_queue_size_of(0)
        end
      end

      describe "revise" do
        it "shouldn't queue anything" do
          release.revise!
          PdfGeneratorAndEmailer.should have_queue_size_of(0)
        end
      end

      describe "finalize" do
        it "should queue an email when finalized" do
          release.revise!
          release.finalize!
          PdfGeneratorAndEmailer.should have_queue_size_of(ChannelPartner.where("able_to_see_releases IS TRUE").count)
        end
      end

    end

    # describe "hotfixes" do
      # hotfix permissions are tested pretty thoroughly in features
    # end

    describe "channel_partners" do
      it "with one whitelist and one blacklist against the other company it should return @dt and @att ids" do
        release.channel_specific_contents.create({ :channel_partner_ids => [@dt.id], :content => "content" })
        release.channel_specific_contents.create({ :channel_partner_ids => [@appdirect.id], :whitelist => false, :content => "more content" })
        release.channel_partners.should include(@dt.id, @att.id)
      end

      it "with only one whitelist, should only return the partners connected to the whitelist" do
        release.channel_specific_contents.create({ :channel_partner_ids => [@dt.id], :content => "content" })
        release.channel_partners.should include(@dt.id)
      end

      it "with only one blacklist, should return every channel partner except the ones in the blacklist" do
        release.channel_specific_contents.create({ :channel_partner_ids => [@appdirect.id], :whitelist => false, :content => "more content" })
        release.channel_partners.should_not include(@appdirect.id)
      end

      it "with no channel specific content should return an empty array" do
        release.channel_partners.should == []
      end
    end

    describe "any_content_for?" do
      let(:superadmin){ FactoryGirl.create(:superadmin, :channel_partner_id => @appdirect.id) }
      let(:empty) { FactoryGirl.create(:release, :present, :empty) }

      it "should return true if there are general notes" do
        release.any_content_for?(user).should == true
      end

      it "should return true if there are no general notes and you're a superadmin" do
        empty.any_content_for?(superadmin).should == true
      end

      it "should return false if there are no general notes and you're a user" do
        empty.any_content_for?(user).should == false
      end

      it "should return true if there are hotfixes for you" do
        empty.stub(:hotfixes_for).with(user).and_return(["1"]) # return any value that .blank? evaluates to false
        empty.any_content_for?(user).should == true
      end

      it "should return true if there are specific notes for you" do
        empty.stub(:notes_for_user?).with(user).and_return(true)
        empty.any_content_for?(user).should == true
      end

    end

  end
end

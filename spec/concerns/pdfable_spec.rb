require 'spec_helper'

describe Pdfable do

  before do
    init_channel_partners
  end

  describe "processing_pdf_for?" do
    it "returns true if there is a task marked processing" 
    it "returns false if there isn't a taks marked processing"
    it "returns false if there is a processing task older than 2 minutes"
    it "returns false if there is a complete task"
    it "returns false if there is a failed task"
  end

  describe "pdf_ready_for?" do
    let(:release) {FactoryGirl.create(:release, :published, :present)}
    it "returns true (ready) when we're not processing a PDF and a PDF exists" do
      release.stub(:processing_pdf_for?) { false }
      release.stub(:pdf_exists_for?) { true}
      expect(release.pdf_ready_for?(:user)).to be_true
    end
    it "returns false (not ready) when we're processing a PDF and a PDF exists" do
      release.stub(:processing_pdf_for?) { true }
      release.stub(:pdf_exists_for?) { true}
      expect(release.pdf_ready_for?(:user)).to be_false
    end
    it "returns false (not ready) we're not processing a PDF and PDF doesn't exist" do
      release.stub(:processing_pdf_for?) { false }
      release.stub(:pdf_exists_for?) { false }
      expect(release.pdf_ready_for?(:user)).to be_false
    end
    it "returns false (not ready) when we're processing a PDF" do
      release.stub(:processing_pdf_for?) { true }
      expect(release.pdf_ready_for?(:user)).to be_false
    end
  end

  describe "generate_pdf hooks" do
    let(:partner_count) { ChannelPartner.count }
    let(:release)       { FactoryGirl.build(:release_with_callbacks, :published, :present) }
    
    before do
      REDIS_WORKER.flushdb
      Resque.inline = true
      ResqueSpec.reset!
      PdfGenerator.any_instance.stub(:mark_as) { true }
    end
    
    context "after_create" do
      
      it "enqueues a PDF for each channel partner" do
        release.save!
        PdfGenerator.should have_queue_size_of(partner_count)
      end

      it "the queue can be queried for a specific channel partner's PDF" do
        release.save!
        PdfGenerator.should have_queued("Release", release.id, ChannelPartner.first.id)
      end

    end
    
    context "after_commit on update" do
      it "enqueues a PDF for each channel partner" do
        release.save! #creates release
        release.save! #updates release
        PdfGenerator.should have_queue_size_of(partner_count*2)
      end
    end
  end

end
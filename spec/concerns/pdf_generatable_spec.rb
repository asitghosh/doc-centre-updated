# encoding: UTF-8
require 'spec_helper'

describe PdfGeneratable do
  before :all do
    init_channel_partners
  end

  before do
    ENV['IS_A_RESQUE_WORKER'] = "true"
  end
  after do
    ENV['IS_A_RESQUE_WORKER'] = "false"
  end

  let(:channel_partner) { @att }
  let(:release) { FactoryGirl.create(:release, :published, :present) }
  let(:generator) { PdfGenerator.new('release', release.id, channel_partner.id) }
  let(:html) { generator.get_html}

  describe "#get_html" do
    it "should get HTML" do
      expect(html).to be_a_kind_of(String)
    end
    it "should render the correct HTML" do
      expect(html).to include(release.marketplace_improvements) 
    end
  end

  describe "#create_pdf" do
    let(:print_status) {""}
    before do
      generator.stub(:doc_task).and_return("status_id" => 123)
    end
    
    it "marks as failed on DocRaptor failure" do
      generator.stub(:doc_status).and_return('status' => 'failed')
      generator.should_receive(:mark_as).and_return("failed")
      
      generator.create_pdf
    end

    it "downloads and saves PDF on DocRaptor complete" do
      generator.stub(:doc_status).and_return('status' => 'completed')
      generator.should_receive(:download_and_save_pdf).and_return(:true)
      
      generator.create_pdf
    end
  end
  # it "sends data to docraptor"
  # it "saves the pdf"
  # it "performs when instantiated"
  # it "marks as processing when enqueued"
  # it "marks as complete when finished"
  # it "marks as failure on failure"
end